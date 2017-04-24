function coded_bits = convolution_encoder(in_bits)
ConvCodeGenPoly=[1 0 1 1 0 1 1;1 1 1 1 0 0 1];
Nrow = size(ConvCodeGenPoly,1);
Nbits=size(ConvCodeGenPoly,2)+length(in_bits)-1;
uncoded_bits=zeros(Nrow,Nbits);
for row=1:Nrow
    uncoded_bits(row,1:Nbits)=rem(conv(in_bits,ConvCodeGenPoly(row,:)),2);
end
coded_bits=uncoded_bits;
end