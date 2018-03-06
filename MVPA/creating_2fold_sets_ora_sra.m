% creating traiing and testing sets 
% written by YSL on Aug 7th 2012
% updated by MJH on Dec 14th 2017

cd(dir_thisrun)
load SPM.mat 

combined_reg_ora = zeros(size(SPM.xX.X, 1), 1);
combined_reg_sra = zeros(size(SPM.xX.X, 1), 1);

%% making combined regressors for ORA and SRA conditions 
for ii = 1:(size(SPM.xX.name, 2)) %total number of regressors 
    if ~isempty(strfind(SPM.xX.name{ii}, 'ORA'))
        combined_reg_ora= [combined_reg_ora, SPM.xX.X(:,ii)];
        combined_reg_ora = sum(combined_reg_ora,2);
    elseif ~isempty(strfind(SPM.xX.name{ii}, 'SRA'))     
        combined_reg_sra= [combined_reg_sra SPM.xX.X(:,ii)];
        combined_reg_sra = sum(combined_reg_sra,2);
    end 
end

%%  making 2 training & testing sets 
% fold1 <testing : run 1, training : run 2> 
ora_tst_set= zeros(size(SPM.xX.X, 1), 1);
sra_tst_set= zeros(size(SPM.xX.X, 1), 1);

if fold == 1
    for ff=1:(size(SPM.xX.name, 2))
        if ~isempty(strfind(SPM.xX.name{ff}, 'Sn(1) ORA')) 
            ora_tst_set = [ora_tst_set, SPM.xX.X(:,ff)];
            ora_tst_set = sum(ora_tst_set, 2);
            ora_trn_set = combined_reg_ora - ora_tst_set; % run 2
        elseif ~isempty (strfind(SPM.xX.name{ff}, 'Sn(1) SRA'))  
            sra_tst_set = [sra_tst_set, SPM.xX.X(:,ff)];
            sra_tst_set = sum(sra_tst_set, 2);
            sra_trn_set = combined_reg_sra - sra_tst_set;
        end
    end

%% fold 2: run 2 <testing : run 2, training : run 1> 

elseif fold == 2
    for ff=1:(size(SPM.xX.name, 2))
        if ~isempty(strfind(SPM.xX.name{ff}, 'Sn(2) ORA')) 
            ora_tst_set = [ora_tst_set, SPM.xX.X(:,ff)];
            ora_tst_set = sum(ora_tst_set, 2);
            ora_trn_set = combined_reg_ora - ora_tst_set; % run 3 through 8 
        elseif ~isempty(strfind(SPM.xX.name{ff}, 'Sn(2) SRA'))  
            sra_tst_set = [sra_tst_set, SPM.xX.X(:,ff)];
            sra_tst_set = sum(sra_tst_set, 2);
            sra_trn_set = combined_reg_sra - sra_tst_set;
        end
    end 
            
% %% fold 3: run 3
% dog_testing_set3= zeros(1,size(SPM.xX.X, 1))';
% human_testing_set3= zeros(1,size(SPM.xX.X, 1))';
% 
% for p=1:(size(SPM.xX.name,2));
%     
%      if    ~isempty (findstr ('Sn(3) dog', SPM.xX.name{p})) 
%         
%              dog_testing_set3=[dog_testing_set3, SPM.xX.X(:,p)];
%              dog_testing_set3=sum(dog_testing_set3,2);
%              dog_training_set3=combined_reg_sra-dog_testing_set3; % run 3 through 8 
%              
%      elseif ~isempty (findstr ('Sn(3) human', SPM.xX.name{p})) 
%        
%    
%              human_testing_set3=[human_testing_set3, SPM.xX.X(:,p)];
%              human_testing_set3=sum(human_testing_set3,2);
%              human_training_set3=combined_reg_ora-human_testing_set3;
%      end
% end
% 
% 
% 
% 
% %% fold 4: run 4
% 
% dog_testing_set4= zeros(1,size(SPM.xX.X, 1))';
% human_testing_set4= zeros(1,size(SPM.xX.X, 1))';
% 
% for p=1:(size(SPM.xX.name,2));
%     
%      if    ~isempty (findstr ('Sn(4) dog', SPM.xX.name{p})) 
%         
%              dog_testing_set4=[dog_testing_set4, SPM.xX.X(:,p)];
%              dog_testing_set4=sum(dog_testing_set4,2);
%              dog_training_set4=combined_reg_sra-dog_testing_set4; % run 3 through 8 
%              
%      elseif ~isempty (findstr ('Sn(4) human', SPM.xX.name{p})) 
%         
%              human_testing_set4=[human_testing_set4, SPM.xX.X(:,p)];
%              human_testing_set4=sum(human_testing_set4,2);
%              human_training_set4=combined_reg_ora-human_testing_set4;
%              
%      end
% end
% 
% 
% %% fold 5: run 5
% 
% dog_testing_set5= zeros(1,size(SPM.xX.X, 1))';
% human_testing_set5= zeros(1,size(SPM.xX.X, 1))';
% 
% for p=1:(size(SPM.xX.name,2));
%     
%      if    ~isempty (findstr ('Sn(5) dog', SPM.xX.name{p})) 
%         
%              dog_testing_set5=[dog_testing_set5, SPM.xX.X(:,p)];
%              dog_testing_set5=sum(dog_testing_set5,2);
%              dog_training_set5=combined_reg_sra-dog_testing_set5; % run 3 through 8 
%              
%      elseif ~isempty (findstr ('Sn(5) human', SPM.xX.name{p})) 
%         
%              human_testing_set5=[human_testing_set5, SPM.xX.X(:,p)];
%              human_testing_set5=sum(human_testing_set5,2);
%              human_training_set5=combined_reg_ora-human_testing_set5;
%              
%      end
% end
% 
% 
% %% fold 6: run 6
% 
% dog_testing_set6= zeros(1,size(SPM.xX.X, 1))';
% human_testing_set6= zeros(1,size(SPM.xX.X, 1))';
% 
% for p=1:(size(SPM.xX.name,2));
%     
%      if    ~isempty (findstr ('Sn(6) dog', SPM.xX.name{p})) 
%         
%              dog_testing_set6=[dog_testing_set6, SPM.xX.X(:,p)];
%              dog_testing_set6=sum(dog_testing_set6,2);
%              dog_training_set6=combined_reg_sra-dog_testing_set6; % run 3 through 8 
%              
%      elseif ~isempty (findstr ('Sn(6) human', SPM.xX.name{p})) 
%         
%              human_testing_set6=[human_testing_set6, SPM.xX.X(:,p)];
%              human_testing_set6=sum(human_testing_set6,2);
%              human_training_set6=combined_reg_ora-human_testing_set6;
%              
%      end
% end
end

cd(dir_MVPA_batch)