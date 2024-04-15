addpath("GitHub\rat-resonator-Matlab\src\boxplotgroup");

ion_ctrl_1
ion_ctrl_2
ion_ctrl_3
ion_ctrl_4
ion_ctrl_5

ion_1
ion_2
ion_3
ion_4
ion_5
ion_6

avg_ion = avg_ion([1 3:6],:);

combined_data = {avg_ion, avg_ctrl};
boxplotGroup(combined_data,'secondaryLabels',{'0-10','10-20','20-30',...
    '30-40','40-50','50-60'},'primaryLabels',{'Experimental Group',...
    'Control Group'})

for i=1:6
    [h(i) p(i)] = ttest(avg_ctrl(:,i),avg_ion(:,i));
end