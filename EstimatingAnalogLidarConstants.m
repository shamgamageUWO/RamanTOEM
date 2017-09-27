%% this is to fit the analog to digital 

% {Corrected digital counts / CJL} = {(analog - bg)/CJLa}
% CJLa =  {(analog - bg)} / {Corrected digital counts / CJL}

% This is using real measurements
            [Q] = makeQsham( 20110909,23,2);
%             x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa 1.9e17 Q.deadtimeJH Q.deadtimeJL];
%             [JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x_a);
% 
%             % Desaturate the digital
            JLDS =Q.JL_DS;
            JHDS =Q.JH_DS;
%             % Remove Bg
            JL_CC = JLDS - Q.BaJL;
            JH_CC = JHDS - Q.BaJH;
%             % divide by CJL
             PC_ratio = JL_CC;
%             % analog remove bg 
            JLan = Q.JLnewa - Q.BaJLa;
% 
            % Measurements between 2-3km
ind1 = Q.Zmes1>3.8e3 & Q.Zmes1<5e3; %JL
ind11 = Q.Zmes2>3.8e3 & Q.Zmes2<5e3; %JL


%             ind = Q.Zmes>1e3 & Q.Zmes<10e3;
             PC_CC_Ratio = PC_ratio(ind1);
             JLa_Range = JLan(ind11);
% 
            CJLa = (JLa_Range.* Q.CL)./PC_CC_Ratio';
             fL = fittype({'x'});
             fitJL = fit(PC_CC_Ratio,Q.CL.*JLa_Range',fL,'Robust','on');
             CJLafit = fitJL(1)
%              figure;plot(CJLa,Q.Zmes(ind));


% Simulations
% 
% %% Method 1:
%  [Q] = makeQsham(20110909,23,2);
% F = 1800.* (3.75./150);
% % First determine the range where PC signal is 5-10MHz use the average
% % signal
% % figure;plot((Q.JLnew./(Q.deltatime.*Q.coaddalt.*F)),Q.Zmes2./1000,'r',(Q.JHnew./(Q.deltatime.*Q.coaddalt.*F)),Q.Zmes2./1000,'b')
% % xlabel('Avg signal (MHz)')
% % ylabel('Alt (km)')
% % legend('JL','JH')
% % CJL = 2.8e20;
% 
% x_a = [Q.Ta 0 0 Q.CL Q.OVa 0 0 Q.CLa 0 0]; % CJL = 2.8e20 No deadtime, so no issue with saturation
% [JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x_a);
% 
% % Idea here is a_JL .*N_JLA + b_JLA = DS{N_JL} = N_JL + B_JL
%  % Measurements between 2-3km
% ind1 = Q.Zmes1>3.8e3 & Q.Zmes1<5e3; %JL
% ind11 = Q.Zmes2>3.8e3 & Q.Zmes2<5e3; %JL
% ind2 = Q.Zmes>2.4e3 & Q.Zmes<3.5e3;% JH
% 
% 
% y = JL(ind11); 
% x = Q.CL.*(JLa(ind1));
% 
% 
% figure;
% % subplot(1,2,1)
% % semilogx(Q.JLnew(ind1)./Q.JLnewa(ind1),Q.Zmes(ind1)./1000)
% % subplot(1,2,2)
% semilogx(JL(ind11)./JLa(ind1),Q.Zmes(ind1)./1000)
% 
% 
% figure;plot(x./y,Q.Zmes(ind1)./1000)

% 
%             % Desaturate the digital
%             JLDS =Q.JL_DS;
%             JHDS =Q.JH_DS;
%             % Remove Bg
%             JL_CC = JLDS - Q.BaJL;
%             JH_CC = JHDS - Q.BaJH;
%             % divide by CJL
%            Y= JL_CC;
%             % analog remove bg 
%             X = Q.CL.*(Q.JLnewa - Q.BaJLa);
% 
% 
%             YY = Y(ind1);
%             XX = X(ind1);
% 
% 
%             figure;plot(XX'./YY,Q.Zmes(ind1)./1000);

%% Method 2
% fL = fittype({'x','1'},'coefficients',{'a1','a2'});
% fitJL = fit(x',y',fL,'Robust','on');
% % Create figure
% figure1 = figure;
% 
% % Create axes
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% 
% % Create plot
% plot1 = plot(x,y,'DisplayName','data1');
% % Get xdata from plot
% xdata1 = get(plot1, 'xdata');
% % Get ydata from plot
% ydata1 = get(plot1, 'ydata');
% % Make sure data are column vectors
% xdata1 = xdata1(:);
% ydata1 = ydata1(:);
% 
% 
% % Remove NaN values and warn
% nanMask1 = isnan(xdata1(:)) | isnan(ydata1(:));
% if any(nanMask1)
%     warning('GeneratedCode:IgnoringNaNs', ...
%         'Data points with NaN coordinates will be ignored.');
%     xdata1(nanMask1) = [];
%     ydata1(nanMask1) = [];
% end
% 
% % Find x values for plotting the fit based on xlim
% axesLimits1 = xlim(axes1);
% xplot1 = linspace(axesLimits1(1), axesLimits1(2));
% 
% % Preallocate for "Show equations" coefficients
% coeffs1 = cell(1,1);
% 
% % Find coefficients for polynomial (order = 1)
% fitResults1 = polyfit(xdata1,ydata1,1);
% % Evaluate polynomial
% yplot1 = polyval(fitResults1,xplot1);
% 
% % Save type of fit for "Show equations"
% fittypesArray1(1) = 2;
% 
% % Save coefficients for "Show Equation"
% coeffs1{1} = fitResults1;
% 
% % Plot the fit
% fitLine1 = plot(xplot1,yplot1,'DisplayName','   linear','Tag','linear',...
%     'Parent',axes1,...
%     'Color',[0.929 0.694 0.125]);
% 
% % Set new line in proper position
% % setLineOrder(axes1,fitLine1,plot1);
% 
% % "Show equations" was selected
% showEquations(fittypesArray1,coeffs1,2,axes1);
% 
% box(axes1,'on');
% % Create legend
% legend(axes1,'show');
% 
% % Now run the new FM and see how the things works.
% 
% % x = [Q.Ta Q.BaJH Q.BaJL CJL Q.OVa 0 0 3.8e-9 3.8e-9];
% % [JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman_NEWANALOG(Q,x);
% % 
% % figure;plot(JLa,Q.Zmes1./1000,'r',Q.JLnewa,Q.Zmes2./1000,'b');
% 
% 
% %-------------------------------------------------------------------------%
% function showEquations(fittypes1, coeffs1, digits1, axesh1)
% %SHOWEQUATIONS(FITTYPES1,COEFFS1,DIGITS1,AXESH1)
% %  Show equations
% %  FITTYPES1:  types of fits
% %  COEFFS1:  coefficients
% %  DIGITS1:  number of significant digits
% %  AXESH1:  axes
% 
% n = length(fittypes1);
% txt = cell(length(n + 1) ,1);
% txt{1,:} = ' ';
% for i = 1:n
%     txt{i + 1,:} = getEquationString(fittypes1(i),coeffs1{i},digits1,axesh1);
% end
% text(.05,.95,txt,'parent',axesh1, ...
%     'verticalalignment','top','units','normalized');
% 
% end
% 
% %-------------------------------------------------------------------------%
% function [s1] = getEquationString(fittype1, coeffs1, digits1, axesh1)
% %GETEQUATIONSTRING(FITTYPE1,COEFFS1,DIGITS1,AXESH1)
% %  Get "Show Equation" text
% %  FITTYPE1:  type of fit
% %  COEFFS1:  coefficients
% %  DIGITS1:  number of significant digits
% %  AXESH1:  axes
% 
% if isequal(fittype1, 0)
%     s1 = 'Cubic spline interpolant';
% elseif isequal(fittype1, 1)
%     s1 = 'Shape-preserving interpolant';
% else
%     op = '+-';
%     format1 = ['%s %0.',num2str(digits1),'g*x^{%s} %s'];
%     format2 = ['%s %0.',num2str(digits1),'g'];
%     xl = get(axesh1, 'xlim');
%     fit =  fittype1 - 1;
%     s1 = sprintf('y =');
%     th = text(xl*[.95;.05],1,s1,'parent',axesh1, 'vis','off');
%     if abs(coeffs1(1) < 0)
%         s1 = [s1 ' -'];
%     end
%     for i = 1:fit
%         sl = length(s1);
%         if ~isequal(coeffs1(i),0) % if exactly zero, skip it
%             s1 = sprintf(format1,s1,abs(coeffs1(i)),num2str(fit+1-i), op((coeffs1(i+1)<0)+1));
%         end
%         if (i==fit) && ~isequal(coeffs1(i),0)
%             s1(end-5:end-2) = []; % change x^1 to x.
%         end
%         set(th,'string',s1);
%         et = get(th,'extent');
%         if et(1)+et(3) > xl(2)
%             s1 = [s1(1:sl) sprintf('\n     ') s1(sl+1:end)];
%         end
%     end
%     if ~isequal(coeffs1(fit+1),0)
%         sl = length(s1);
%         s1 = sprintf(format2,s1,abs(coeffs1(fit+1)));
%         set(th,'string',s1);
%         et = get(th,'extent');
%         if et(1)+et(3) > xl(2)
%             s1 = [s1(1:sl) sprintf('\n     ') s1(sl+1:end)];
%         end
%     end
%     delete(th);
%     % Delete last "+"
%     if isequal(s1(end),'+')
%         s1(end-1:end) = []; % There is always a space before the +.
%     end
%     if length(s1) == 3
%         s1 = sprintf(format2,s1,0);
%     end
% end
% end
% 
% 
