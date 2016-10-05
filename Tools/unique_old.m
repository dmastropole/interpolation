function [unique_vector,a,b]=unique_old(vector)

    unique_vector=unique(vector);
    [sorted_vector,s]=sort(vector);
    unique_sorted_vector=unique(sorted_vector);
    
    a=[];
    for j=1:length(unique_sorted_vector)
        ai=find(sorted_vector==unique_sorted_vector(j));
        aii=max(s(ai));
        a=[a; aii];
    end
    
    b=[];
    for i=1:length(unique_vector)
        bi=find(vector==unique_vector(i));
        b(bi)=i;
        clear bi;
    end
    
    
end


