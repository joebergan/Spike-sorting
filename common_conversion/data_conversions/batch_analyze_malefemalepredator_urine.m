function batch_analyze_malefemalepredator_urine(PTHRESH, take_units)

% Analyze populations and specific cases of the sex * strain experiment
% This can be run after "load  analye_urine_strain_data" generated by 
%  make_data_for_analyze_urine_sexstrain.m

if nargin<2
    disp('default values used')
    PTHRESH = 0.01;
    % take_units = 'Single';
    take_units = 'MUA+Single';
end

disp('hello')
PTHRESH
disp('goodbye')


% Compare the first odor group to all the rest to make sure they are all
% the same - you know, just checking ...
firstodors = odors{1};
for i = 2:length(odors)
    theseodors = odors{i};
    if length(theseodors) ~= length(firstodors)
        disp('mismatch in number of odor names !!')
    else
        for k = 1:length(firstodors)
            res = strcmp(theseodors{k},firstodors{k});
            if ~res
                disp('mismatch in odor names')
            end
        end
    end
end

% Construct arrays of all relevant data, which will including response properties (also to control stimuli and to suction), sex, grades, etc
BASELINES = [];
SHAPES = [];
MODS = [];
PEAKS = [];
%MODsems  = [];
%PEAKsems = [];
PVAL       = [];
PVAL_ALLBS = [];
PVAL_NP   = [];
PVAL_NP_ALLBS = [];
PVAL_NP_MIN = [];

GRADES = [];
UNIT_NUMS = [];
SR = []; % Response for any of the two relevant stimuli
%AR = []; % AR is for any response whatsoever, on the sitmulation that is
MOBR = [];
SESSION_INDS = [];
SESSION_NUMS = [];
SESSION_DATES = [];
for i = 1:length(meanM)
    
    
    % This rearrangement of the date facilitates looking for the data for a
    % particular unit
    clear thesedates;
    for k = 1:length(meanM{i})
        thesedates{k} = sessiondate{i};
    end
    SESSION_DATES = [SESSION_DATES; thesedates'];
    SESSION_NUMS = [SESSION_NUMS ;  thissession{i}*ones(size(meanM{i},1),1) ];    % whether 1st or second session etc
        
    % responses to stimuli
    SR = [SR ;  AllFoundResponse{i}(:,1:end)];
    % We consider a unit to be MOB responsive if it shows responses to start clean on more than two odorants
    MOBR = [MOBR ; sum(MOBAllFoundResponse{i},2) > 2];
    MODS  = [MODS ; meanM{i}];
    %MODsems  = [MODsems ; semM{i}];
    %PEAKsems  = [PEAKsems ; semP{i}];
    PEAKS  = [PEAKS ; meanP{i}];   
    PVAL       = [PVAL; pval{i}];
    PVAL_ALLBS = [PVAL_ALLBS; pval_allbs{i}];
    PVAL_NP   = [PVAL_NP; pval_np{i}];
    PVAL_NP_ALLBS = [PVAL_NP_ALLBS; pval_np_allbs{i}];
    PVAL_NP_MIN = [PVAL_NP_MIN; pval_np_min{i}];
    UNIT_NUMS = [UNIT_NUMS ; unit_nums{i}];
    GRADES = [GRADES unit_grades{i}];
    SHAPES = [SHAPES unit_shapes{i}];
    BASELINES = [BASELINES unit_baselines{i}];
    SESSION_INDS = [SESSION_INDS ;  i*ones(size(meanM{i},1),1) ];    
end

% Based on this data, I will analyze specific case 
% This is the original order, wnich I want to display differently
% These are the stimuli to look for at the given concentrations
% These are the stimuli to look for at the given concentrations
% No need to reorder these sitmuli
rel_stims{1} = 'F_U_100F';
rel_stims{2} = 'M_U_100F';
rel_stims{3} = 'P_U_100F';


ord = [1:3];
odors{1}(ord)


% Select single units that are not airflow responsive
for i = 1:length(GRADES)
    if ~isempty(strfind(lower(GRADES{i}),'single'));
        SINGLE_IND(i) = 1;
    else
        SINGLE_IND(i) = 0;
    end
end
% The first line is for single units, the second line for all units
switch take_units
    case 'Single';
        rel_inds = find(SINGLE_IND & ~MOBR');
    case 'MUA+Single';
        rel_inds = find(~MOBR');
end
disp(['number of UNITS: ' num2str(length(rel_inds))])




% Normalize the response matrices (for plotting)
for i = 1:length(MODS)
    normMODS(i,:) = MODS(i,:)./max(abs(MODS(i,:)));
    normPEAKS(i,:) = PEAKS(i,:)./max(abs(PEAKS(i,:)));
end
% order odors according to the stimuli
nonormMODS = MODS(rel_inds,ord); 
relMODS = normMODS(rel_inds,ord); % Responses
relPEAKS = normPEAKS(rel_inds,ord); % Responses
relPS   = PVAL_NP_ALLBS(rel_inds,ord); % significane matrix
relUNIT_NUMS = UNIT_NUMS(rel_inds);
relSESSION_NUMS = SESSION_NUMS(rel_inds);
relSESSION_DATES = SESSION_DATES(rel_inds);


% Provide a t4ext display of the asociated units
for i = 1:length(rel_inds)
    disp([num2str(i) '. ' num2str(relUNIT_NUMS(i)) ' ' relSESSION_DATES{i} ' ' num2str(relSESSION_NUMS(i)) ' ']);
    disp(relMODS(i,ord))
    disp(relPS(i,ord))    
    disp([' -  ']);
end



% Find significant responses
sigmat = (relPS(:,:) < PTHRESH);
signmat = sign(relMODS(:,:));
anysig = find(sum(sigmat'));

% Statistics of the number of positive and negative responses
% Find positive and negative significant responses
signsigmat = signmat.* sigmat; % Sign of significant responses
possigmat = signsigmat > 0;
negsigmat = signsigmat < 0;


% Make a histgoram of the number of negative and positive responses
% for each unit
figure;
subplot(1,2,1);
N1 = sum(possigmat');
hist(N1,[0:3]);
title(['positive responses n = ' num2str(length(N1))])
xlabel('n stimuli')
set(gca,'xlim',[-1 4],'ylim',[0 50])
subplot(1,2,2);
N2 = sum(negsigmat');
hist(N2,[0:3]);
title('negative responses')
xlabel('n stimuli')
set(gca,'xlim',[-1 4],'ylim',[0 50])


% Matrices including only significant responses
fulsigMODS = nonormMODS(anysig,:); 
sigMODS = relMODS(anysig,:);
sigPEAKS = relPEAKS(anysig,:);
sigSIGS = sigmat(anysig,:);
sigSIGNS = signsigmat(anysig,:);
nsigs = sum(sigSIGS');


clear sigcode
for i = 1:length(sigMODS)
    sigcode(i) = sigSIGS(i,1)* 100 + sigSIGS(i,2)* 10 + sigSIGS(i,3) - 0.5*sum([sigSIGNS(i,:) < 0]);
end


female_inds = find(sigcode == 100);
male_inds = find(sigcode == 10);
predator_inds = find(sigcode == 1);

mean_fem_resp = mean(fulsigMODS(female_inds,1));
mean_male_resp = mean(fulsigMODS(male_inds,2));
mean_pred_resp = mean(fulsigMODS(predator_inds,3));

SD_fem_resp = std(fulsigMODS(female_inds,1));
SD_male_resp = std(fulsigMODS(male_inds,2));
SD_pred_resp = std(fulsigMODS(predator_inds,3));

disp(['mean female response:   ' num2str(mean_fem_resp) ' SD: ' num2str(SD_fem_resp) ' N =  ' num2str(length(female_inds))])
disp(['mean male response:     ' num2str(mean_male_resp) ' SD: ' num2str(SD_male_resp) ' N =  ' num2str(length(male_inds))])
disp(['mean predator response: ' num2str(mean_pred_resp) ' SD: ' num2str(SD_pred_resp) ' N =  ' num2str(length(predator_inds))])


% This ensures that the number of significant values is the dominant
% parameter
fulsortcode = sigcode + nsigs*1000;


% % Now sort them by the number of sigfnificant values
%[tmp sort1] = sort(nsigs);
[tmp sort1] = sort(fulsortcode);
sigMODS  = sigMODS(sort1,:);
sigPEAKS = sigPEAKS(sort1,:);
sigSIGS  = sigSIGS(sort1,:);
sigSIGNS = sigSIGNS(sort1,:);
fulsigMODS  = fulsigMODS(sort1,:);



% A histogram of the different response types
clear simp_sigcode
for i = 1:length(sigMODS)
    % simp_sigcode(i) = sigSIGS(i,1)* 100 + sigSIGS(i,2)* 10 + sigSIGS(i,3);
    simp_sigcode(i) = sigSIGNS(i,1)* 100 + sigSIGNS(i,2)* 10 + sigSIGNS(i,3);    
end
% i will do it the dumb way
clear Nc
Nc(1) = length(find(simp_sigcode == 1)); % pred
Ncat{1} = 'P';
Nc(2) = length(find(simp_sigcode == 10)); % 
Ncat{2} = 'M';
Nc(3) = length(find(simp_sigcode == 100));
Ncat{3} = 'F';
Nc(4) = length(find(simp_sigcode == 101));
Ncat{4} = 'F+P';
Nc(5) = length(find(simp_sigcode == 110));
Ncat{5} = 'M+F';
Nc(6) = length(find(simp_sigcode == 11));
Ncat{6} = 'M+P';
Nc(7) = length(find(simp_sigcode == 111));
Ncat{7} = 'M+F+P';


figure
bar(Nc)
set(gca,'xtick',1:length(Nc))
set(gca,'xticklabel',Ncat)
title(['response distributions p<' num2str(PTHRESH) ])
%set(gca,'ylim',[0 18])
xlabel('category')

%Y = pdist(sigPEAKS','correlation');
% distfun = 'correlation';
distfun = 'euclidean';
Y = pdist(fulsigMODS',distfun);
%Y = pdist(sigMODS',distfun);
Z = linkage(Y,'average');
figure
[H,T] = dendrogram(Z,'colorthreshold','default');

origlabel = get(gca,'xticklabel');
origlabel = str2num(origlabel);
orignames = odors{1};
for i = 1:length(origlabel)
    shortlabel{i} = orignames{origlabel(i)};
end
set(gca,'xticklabel',shortlabel)
title([distfun ' ' num2str(PTHRESH)])


 figure
imagesc(sigSIGNS);
load sigcmap
colormap(sigcmap)
%colorbar
set(gca,'xticklabel',odors{1}(ord),'xtick',[1:3])
set(gca,'fontsize',7)
title('significant responses x their signs')

xticks = get(gca,'xtick') + 0.5;
yticks = get(gca,'ytick') + 0.5;
xlims = get(gca,'xlim');
ylims = get(gca,'ylim');

for  i = 0:ceil(xlims(2))
    lh = line([i + 0.5 i + 0.5],[ylims(1)-0.5 ylims(2)+0.5]);
    set(lh,'color','w','linewidth',0.25);
end
for  i = 0:ceil(ylims(2))
    lh = line([xlims(1)-0.5 xlims(2)+0.5],[i + 0.5 i + 0.5]);
    set(lh,'color','w','linewidth',0.5);
end


% figure
% imagesc(sigMODS);
% load cmap
% colormap(cmap)
% colorbar
% set(gca,'xticklabel',odors{1}(ord),'xtick',[1:3])
% set(gca,'fontsize',7)
% title('significant responses magnitude')
% 
% figure
% imagesc(sigPEAKS);
% colormap hot
% colorbar
% set(gca,'xticklabel',odors{1}(ord),'xtick',[1:3])
% set(gca,'fontsize',7)
% title('significant responses peaks')



