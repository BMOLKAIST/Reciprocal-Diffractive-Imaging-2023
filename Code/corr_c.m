function correlation = corr_c(array1, array2)

    correlation = abs(array1(:)'*array2(:)/norm(array1(:))/norm(array2(:)));

end
