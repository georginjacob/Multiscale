figure_05; % Visual Search Primary Analysis
close all;
%% Congruent and Incongruent
congruent_distances=[];
incongruent_distances=[];
congruent_distances_dpre=[];
incongruent_distances_dpre=[];

for i=1:size(img_pairs,1)
    g1=L2_str.Image_Pair_Details(i,1);
    l1=L2_str.Image_Pair_Details(i,2);
    g2=L2_str.Image_Pair_Details(i,3);
    l2=L2_str.Image_Pair_Details(i,4);
    if (g1==l1&&g2==l2)
        congruent_distances=[congruent_distances;dobs(i)];
        congruent_distances_dpre=[congruent_distances_dpre;dpre(i)];
    elseif((g1==l2)&&(g2==l1))
        incongruent_distances=[incongruent_distances,dobs(i)];
        incongruent_distances_dpre=[incongruent_distances_dpre,dpre(i)];
    end
end
mean_congruent_distance=mean(abs(congruent_distances));
sem_congruent=std(congruent_distances)/sqrt(21);
mean_incongruent_distance=mean(abs(incongruent_distances));
sem_incongruent=std(incongruent_distances)/sqrt(21);
subplot 121
bar([mean_congruent_distance,mean_incongruent_distance])
hold on
errorbar( [mean_congruent_distance,mean_incongruent_distance],[sem_congruent,sem_incongruent]);
xlabel('congruent                 incongruent');
ylabel('Mean observed dissimilarity')
title('Observed Incongruence')

mean_congruent_distance_dpre=mean(abs(congruent_distances_dpre));
sem_congruent_dpre=std(congruent_distances_dpre)/sqrt(21);
mean_incongruent_distance_dpre=mean(abs(incongruent_distances_dpre));
sem_incongruent_dpre=std(incongruent_distances_dpre)/sqrt(21);
subplot 122
bar([mean_congruent_distance_dpre,mean_incongruent_distance_dpre])
hold on
errorbar( [mean_congruent_distance_dpre,mean_incongruent_distance_dpre],[sem_congruent_dpre,sem_incongruent_dpre]);
xlabel('congruent                 incongruent');
ylabel('Mean predicted dissimilarity')
title('Predicted Incongruence')