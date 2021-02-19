function [c1,c2,sigma1,sigma2,NI,NO,c1_c2_computed]=get_param(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object)

%%estimation of the parameters
    NI=0;
    NO=0;
    sigma1=0;
    sigma2=0;
%%


    if (c1==-2 && c2==-2)
        if (normalise)
             if (smoothing_for_region_values>1)
                    Imagee2=Imagee;
                    h = ones(smoothing_for_region_values,smoothing_for_region_values)/smoothing_for_region_values^2;
                    Imagee=imfilter(Imagee,h);
             end;
            LOW_HIGH = stretchlim(Imagee);
            Imagee2=imadjust(Imagee,LOW_HIGH);
        else
            Imagee2=Imagee;
        end

        ref_im=imrotate(get_model(param.resol),-param.alpha);
        ref_im2=zeros(size(Imagee,1),size(Imagee,2));
        ref_im2(round(param.Ycenter/param.resol-size(ref_im,1)/2):round(param.Ycenter/param.resol+size(ref_im,1)/2),round(param.Xcenter/param.resol-size(ref_im,2)/2):round(param.Xcenter/param.resol+size(ref_im,2)/2))=imadjust(ref_im);
        ref_im3=(ref_im2>0.5);
        c1=mean2(Imagee2(ref_im3));
        c2=mean2(Imagee2(~ref_im3));
        c1_c2_fixed=1;
    else
        c1_c2_fixed=0;
    end
%%

    if (normalise)
        if (smoothing_for_region_values>1)
            Imagee2=Imagee;
            h = ones(smoothing_for_region_values,smoothing_for_region_values)/smoothing_for_region_values^2;
            Imagee=imfilter(Imagee,h);
        end;
        LOW_HIGH = stretchlim(Imagee);
        [count,X]=imhist_over(imadjust(Imagee,LOW_HIGH),imhist_nb);

        index=1;
        while (index<=size(count,1))
            if (count(index)==0)
                count(index)=[];
                X(index)=[];
            else
                index=index+1;
            end
        end;

        fig1=figure_perso;
        result=fit_test(X(6:(size(X,1)-5)),count(6:(size(count,1)-5)),c1_c2_fixed,c1);
        fig2=figure_perso;
        result2=fit_test(X(6:(size(X,1)-5)),count(6:(size(count,1)-5)).*double((((count(6:(size(count,1)-5))-result(X(6:(size(count,1)-5))))./(count(6:(size(count,1)-5))+result(X(6:(size(count,1)-5)))))>(1-1e-10))),c1_c2_fixed,c2);
        if (result.b1>result2.b1)
            c1_=result.b1;
            c2_=result2.b1;
            sigma1_=result.c1/sqrt(2);
            sigma2_=result2.c1/sqrt(2);
        else
            c1_=result2.b1;
            c2_=result.b1;
            sigma1_=result2.c1/sqrt(2);
            sigma2_=result.c1/sqrt(2);
        end
        c1_=c1_*(LOW_HIGH(2)-LOW_HIGH(1))+LOW_HIGH(1); %inside
        c2_=c2_*(LOW_HIGH(2)-LOW_HIGH(1))+LOW_HIGH(1); %outside
        sigma1_=(LOW_HIGH(2)-LOW_HIGH(1))*sigma1_;
        sigma2_=(LOW_HIGH(2)-LOW_HIGH(1))*sigma2_;
        level=(c1_-c2_)*sigma2_/(sigma1_+sigma2_)+c2_;
        Imagee=Imagee2;
        Imagee=round(65535*((Imagee>level).*((sigma2_/sigma1_)*Imagee+level*(1-sigma2_/sigma1_))+(Imagee<=level).*Imagee))/65535;
        Imagee=imadjust(Imagee);
        %for debugging purpose only
        fig_a=figure_perso; subplot_perso(1,2,1); [count_,X_]=imhist_over(imadjust(Imagee),imhist_nb); plot_perso(X_,count_);
        subplot_perso(1,2,2); [count_,X_]=imhist_over(imadjust(Imagee_),imhist_nb); plot_perso(X_,count_);
        %end of debbugging
        %for debugging purpose only
        close_perso(fig_a); close_perso(fig1); close_perso(fig2);
        %end debbug
    end
    
%%
    c1_c2_computed=0;
    if ((c1>1) || (c1<0) || (c2>1) || (c2<0))
        if (smoothing_for_region_values>1)
            Imagee2=Imagee;
            h = ones(smoothing_for_region_values,smoothing_for_region_values)/smoothing_for_region_values^2;
            Imagee=imfilter(Imagee,h);
        end;
        c1_c2_computed=1;
        LOW_HIGH = stretchlim(Imagee);
        [count,X]=imhist_over(imadjust(Imagee,LOW_HIGH),imhist_nb);
        index=1;
        while (index<=size(count,1))
            if (count(index)==0)
                count(index)=[];
                X(index)=[];
            else
                index=index+1;
            end
        end;
        fig1=figure_perso;
        result=fit_test(X(6:(size(X,1)-5)),count(6:(size(count,1)-5)),c1_c2_fixed,c1);
        fig2=figure_perso;
        result2=fit_test(X(6:(size(X,1)-5)),count(6:(size(count,1)-5)).*double((((count(6:(size(count,1)-5))-result(X(6:(size(count,1)-5))))./(count(6:(size(count,1)-5))+result(X(6:(size(count,1)-5)))))>(1-1e-10))),c1_c2_fixed,c2);
        if (result.b1>result2.b1)
            c1=result.b1;
            c2=result2.b1;
            sigma1=result.c1/sqrt(2);
            sigma2=result2.c1/sqrt(2);
        else
            c1=result2.b1;
            c2=result.b1;
            sigma1=result2.c1/sqrt(2);
            sigma2=result.c1/sqrt(2);
        end
        c1=c1*(LOW_HIGH(2)-LOW_HIGH(1))+LOW_HIGH(1);
        c2=c2*(LOW_HIGH(2)-LOW_HIGH(1))+LOW_HIGH(1);
        sigma1=(LOW_HIGH(2)-LOW_HIGH(1))*sigma1;
        sigma2=(LOW_HIGH(2)-LOW_HIGH(1))*sigma2;
        level=(c1-c2)*sigma2/(sigma1+sigma2)+c2;
        if (~absolute_lamba_X)
            level=(c1-c2)*sigma2/(sigma1+sigma2)+c2;
            BW=im2bw(Imagee,level);
            %debug purpose
            fig_b=figure_perso; imshow_perso(BW);
            axis xy % very important for reprensenting in direct axes
            %end debug
            NI=sum(sum(BW,1),2);
            NO=prod(size(Imagee))-NI;
            close_perso(fig_b); 
        end
        if (black_object)
            c3=c1; c1=c2; c2=c3;
            c3=sigma1; sigma1=sigma2; sigma2=c3;
            if (~absolute_lamba_X) c3=NI; NI=NO; NO=c3; end
        end
        if (smoothing_for_region_values>1)
            Imagee=Imagee2;
        end
        %for debugging purpose only
        close_perso(fig1); close_perso(fig2);
        %end debug
    end
