%%Step 1%%%%%%%%%%%%%%%%%%%% SETUP 
w = 32;
f = 16;
val = 49650.3703460693359375;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 27544.5947113037109375;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 32702.165191650390625;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 23768.479248046875;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 10930.1126556396484375;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 20612.077117919921875;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 38944.610687255859375;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 49358.790313720703125;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 27961.882659912109375;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

w = 32;
f = 16;
val = 10014.2051544189453125;
x = fi(val, 0, w, f);
x.bin;
fxp_rsqrt2(x);

function y = fxp_rsqrt2(x)
   w = x.WordLength;
   f = x.FractionLength;
   Fm = fimath('RoundingMethod','Floor','OverflowAction','Wrap','ProductMode','SpecifyPrecision','ProductWordLength',w,'ProductFractionLength',f,'SumMode','SpecifyPrecision','SumWordLength',w,'SumFractionLength',f);

   x = fi(x.data,0,w,f,Fm);
   
   xbin = x.bin;
   n = 1;
   z = 0;
    while xbin(n) ~= '1'
            n = n + 1;
            z = z + 1;
    end 
    z;
    %Step 2%%%%%%%%%%%%%%%%%%%%% FIND BETA
    b = w - f - z - 1;
    beta = fi(b,1,w,f,Fm);
    
    
    %Step 3%%%%%%%%%%%%%%%%%%%%% FIND ALPHA
    temp = mod(beta.data,2);
    if temp~= 0
        alpha = -bitsll(beta,1)+bitsra(beta,1)+.5;
    else
        alpha = -bitsll(beta,1)+bitsra(beta,1);
    end
    %Step 4%%%%%%%%%%%%%%%%%%%%% FIND XALPHA
    if alpha.data > 0
        xa = bitsll(x, alpha);

    else
        xa = bitsra(x, abs(alpha));
    end 
    xa_decimal = xa.dec;
    xa_binary = xa.bin;
    xa_hex = xa.hex;
    
    %step 5%%%%%%%%%%%%%%%%%%%%% FIND XBETA
    
     if beta.data > 0
        xb = bitsra(x, beta);
     else
        xb = bitsll(x, abs(beta));
     end
     
     
     xb_decimal = xb.dec;
     xb_binary = xb.bin;
     xb_hex = xb.hex;
     
     %step 6%%%%%%%%%%%%%%%%%%%%% SIMULATE LOOKUPTABLE
     xbd = double(xb)^(-3/2);
     xb = fi(xbd, 0, w, f, Fm);
     disp(xbd);
     
     %step 7%%%%%%%%%%%%%%%%%%%%% CALCULATE FINAL GUESS AND COMPARE TO
     %ACTUAL RESULT
     
    if temp~= 1
        y = xa*xb;
    else
        y = xa*xb*.71;
    end
     y;
     y.hex
     y.bin;
     y_actual = 1/sqrt(double(x.data));
     
end