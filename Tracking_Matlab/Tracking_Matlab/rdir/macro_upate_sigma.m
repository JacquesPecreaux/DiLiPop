% macro macro_upate_sigma
if memory>0 && (real_t<=(2+memory))
                sigma_used=sigma*(real_t-2)/memory;
                msg=sprintf('      new sigma_used = %g',sigma_used);
                disp(msg);
            else
                sigma_used=sigma;
            end;
