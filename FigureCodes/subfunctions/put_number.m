function put_number(N)
count=0;
for i=1:N
    for j=1:N
        count=count+1;
        text(i,j,num2str(count),'Color','white')
    end
end
end