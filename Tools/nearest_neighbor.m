function [new_vec,I]=nearest_neighbor(A,B)
%this function takes two vectors A, and B, and finds the elements in A
%which are closest to those in B.  new_vec is composed of elements in A
%closest to elements of B, and I is a vector of the indices in A nearest
%those of B.  

for i=1:length(B)
    [~,id]=min(abs(A-B(i)));
    a=A(id);
    new_vec(i)=a;
    I(i)=id;
end

end