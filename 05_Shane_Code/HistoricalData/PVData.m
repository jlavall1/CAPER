k = 1;
for i = 1:12
for j = k:max(M_PVSITE_2(i).DAY(:,6))
DATA(k).PV2 = M_PVSITE_2(i).DAY(find(M_PVSITE_2(i).DAY(:,6)==k),1);
k=k+1;
end
end