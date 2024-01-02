%% Examine the momentum effect

clear
close all

return_m_hor=readtable('return_monthly.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');

return_m=stack(return_m_hor,3:width(return_m_hor),'NewDataVariableName','return_m',...
'IndexVariableName','date');
return_m.date=char(return_m.date);
return_m.datestr=datestr(return_m.date);
return_m.date=datetime(return_m.datestr,'InputFormat','dd-MMM-yyyy','Locale','en_US');
return_m.return_m=return_m.return_m/100;

% Read the file with previous month market capitalizaiton 

market_cap_lm_hor=readtable('me_lag.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');
market_cap_lm=stack(market_cap_lm_hor,3:width(market_cap_lm_hor),'NewDataVariableName','lme',...
'IndexVariableName','date');
market_cap_lm.date=char(market_cap_lm.date);
market_cap_lm.datestr=datestr(market_cap_lm.date);
market_cap_lm.date=datetime(market_cap_lm.datestr,'InputFormat','dd-MMM-yyyy','Locale','en_US');

% merge two files 
return_monthly=outerjoin(return_m,market_cap_lm,'Keys',{'date','code','name','datestr'},'MergeKeys',true,'Type','left');
return_monthly=sortrows(return_monthly,{'code','date'},{'ascend','ascend'});

index=~isnan(return_monthly.lme);
return_monthly=return_monthly(index,1:end);

save return_m.mat return_monthly;

%%  examine momentum strategy by creating a dateset with previous stock returns information


load('return_m.mat');

% num_obs is the number of observatiosn in the sample 

[G,jdate]=findgroups(return_monthly.date);
num_obs=length(jdate);

% jdate is another index for indexing the dataset 

return_monthly.jdate=G;

%frequency=[1,3,6,12,24];
frequency=[3];

mom_old=table();

tic 

for i=frequency
        
    % We need frequency(i) points before and after for this strategy
    for j=[i: num_obs-i]
        % pick up previous frequency(i) months returns and need an index for
        % selection for relevant observation
         temp_date=[floor(j/i)*i-i+1:floor(j/i)*i-i+i];
         start_date=j+1;
         % furthermore, this date is updated every i months
   

        % this returns the relevent index for picking up returns 
        index_i=(return_monthly.jdate==temp_date);
       %  creates a composite index where the sample condition is met 
        index=logical(sum(index_i,2));
        mom_sample=return_monthly(index,1:end);
        

        
       % next calculate the previous months' cumulative return for later
       % portfolio analysis 
       [G,code]=findgroups(mom_sample.code);
       pr_return=splitapply(@(x)sum(x),mom_sample.return_m,G);
       pr_return_table=table(code,pr_return);
       % merge it back to mom_smaple to enhance the vector of previous
       % return
       
       index_r=(return_monthly.jdate==start_date);
       mom_r=return_monthly(index_r,1:end);


       mom_sample1=outerjoin(mom_r,pr_return_table,'Keys',{'code'},'MergeKeys',true,'Type','left');
       
       % keep only the last obervation for each firm for later analysis
       %mom_sample2=mom_sample1(mom_sample1.jdate==j+1,:);  %
       % next merge the sample back to the full dataset for each iteration 

       %return_full=outerjoin(return_monthly,mom_sample2(:,{'code','pr_return','jdate'}),'Keys',{'code','jdate'},'MergeKeys',true,'Type','left');
       
       return_full=vertcat(mom_old, mom_sample1); 
       
       mom_old=return_full;
        
    end

end

toc

%%

% return_full is the new dataset with previous K=frequency months return 
% Next is to use the usual portfolio analysis of dividing into five
% portfolios 

% Create percentiles functions

for i=20:20:80
   eval(['prctile_',num2str(i),'=','@(input)prctile(input,i)',';']);
end

% Calcualte percentiles

for x=20:20:80
                eval(['b','=','prctile_',num2str(x),'(return_full.pr_return)',';']);
                eval(['return_full.mom',num2str(x),'=','b*ones(size(return_full,1),1)',';']);
end

return_full.mom_label=rowfun(@mom_bucket_5,return_full(:,{'pr_return','mom20','mom40','mom60'...
                ,'mom80'}),'OutputFormat','cell');
            
return_full.ew=ones(size(return_full,1),1);        
            
            
[G,jdate,mom_label]=findgroups(return_full.date, return_full.mom_label);

ewret=splitapply(@wavg,return_full(:,{'return_m','ew'}),G);

ewret_table=table(jdate,mom_label,ewret);

mom_factors=unstack(ewret_table(:,{'ewret','jdate','mom_label'}),'ewret','mom_label');

A=nanmean(table2array(mom_factors(:,2)))*100;

E=nanmean(table2array(mom_factors(:,6)))*100;

fprintf('The average return for the low previous return group is %4.3f percent per month \n',A)

fprintf('The average return for the high previous return group is %4.3f percent per month \n',E)

%% PCA and MOM factor

% Let us illusrate this for $K=3$

mom_pca=table2array(mom_factors(:,2:6));

[coefMatrix score latnt tsquared explainedVar]=pca(mom_pca); %array_data instead of mom_pca

factors=mom_pca*coefMatrix(:,1:5);

plot(coefMatrix(:,1:3),'-x');
legend('First','Second','Third')


mom=mom_pca(:,5)-mom_pca(:,1);

corr(factors(:,1),mom)

corr(factors(:,2),mom)

corr(factors(:,3),mom)

corr(factors(:,4),mom)

corr(factors(:,5),mom)







