function defuzzfun = coa(xmf, ymf)

    totalArea = sum(ymf);
    defuzzfun = sum(ymf .* xmf') / totalArea;

end