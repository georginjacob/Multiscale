figure_03; % Running the SD analysis;
close all;
%%
figure('units','normalized','outerposition',[0 0 1 1])
subplot 121
[Rgvs,Pgvs,RLgvs,RUgvs]=corrcoef([GL_DG,DG],'alpha',0.3173);Rgvs=Rgvs(2);RLgvs=RLgvs(2);RUgvs=RUgvs(2);
[Rlvs,Plvs,RLlvs,RUlvs]=corrcoef([GL_DL,DG],'alpha',0.3173);Rlvs=Rlvs(2);RLlvs=RLlvs(2);RUlvs=RUlvs(2);
bar([Rgvs,Rlvs]);hold on;
errorbar([1,2],[Rgvs,Rlvs],[Rgvs-RLgvs,Rlvs-RLlvs],[RUgvs-Rgvs,RUlvs-Rlvs])
set(gca,'XTickLabel',{'VS-Global','VS-Local'},'YTick',[-0.2,0.7]);
ylabel('Correlation with Global Distinctiveness, SD Task');
title('Comparing Global Distinctiveness in SD Task ')
ylim([-0.2,0.7])
subplot 122
[Rgvs,Pgvs,RLgvs,RUgvs]=corrcoef(GL_DG,DL,'alpha',0.3173);Rgvs=Rgvs(2);RLgvs=RLgvs(2);RUgvs=RUgvs(2);
[Rlvs,Plvs,RLlvs,RUlvs]=corrcoef(GL_DL,DL,'alpha',0.3173);Rlvs=Rlvs(2);RLlvs=RLlvs(2);RUlvs=RUlvs(2);
bar([Rgvs,Rlvs]);hold on;
errorbar([1,2],[Rgvs,Rlvs],[Rgvs-RLgvs,Rlvs-RLlvs],[RUgvs-Rgvs,RUlvs-Rlvs])
set(gca,'XTickLabel',{'VS-Global','VS-Local'},'YTick',[-0.2,0.7]);
ylabel('Correlation with Local Distinctiveness, SD Task');
title('Comparing Local Distinctiveness in SD Task ')
ylim([-0.2,0.7])