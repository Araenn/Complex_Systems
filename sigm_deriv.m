function a = sigm_deriv(b)
    f = sigm(b);
    a = f * (1-f);
end