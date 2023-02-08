function FM(app)
    cla(app.UIAxes,'reset');
    cla(app.UIAxes2,'reset');
    cla(app.UIAxes3,'reset');
    cla(app.UIAxes4,'reset');
    cla(app.UIAxes5,'reset');
    cla(app.UIAxes6,'reset');
    app.UIAxes.Visible  = 'off';
    app.UIAxes2.Visible  = 'off';
    app.UIAxes3.Visible  = 'off';
    app.UIAxes4.Visible  = 'off';
    app.UIAxes5.Visible  = 'off';
    app.UIAxes6.Visible  = 'off';

    %%------------< EXP 3.1 >------------
    if app.counter == 1
    	% Getting Spectrum of audio signal
        app.UIAxes2.Visible  = 'on';
        app.fs_y = app.n / app.ty;
        app.fshift = (app.fs_y/2) * linspace(-1,1,app.fs_y);
        app.freq_y = fftshift(fft(app.y));
        app.fft_y = fftshift(fft(app.y, numel(app.fshift)));

        % Plotting the spectrum of the audio signal
        plot(app.UIAxes2,app.fshift, abs(app.fft_y)); 
        xlabel(app.UIAxes2,'Frequency (Hz)');
        ylabel(app.UIAxes2,'M (f)');
        title(app.UIAxes2,'Audio signal Spectrum');
    

    %%------------< EXP 3.2 >------------
        app.band_limit = floor(app.fn + app.ty);
        
        % Filter for the plotted signal LPF with 4KHZ cutoff frequency
        app.plotting_filter = cat(1, zeros([app.Fs/2-4e3, 1]), ones([4e3, 1]), ones([4e3, 1]), zeros([app.Fs/2-4e3,1]));
        
        % Filter for the actual signal LPF with 4KHZ cutoff frequency with ideal filter
        app.filter = cat(1, zeros([app.n/2-app.band_limit, 1]), ones([app.band_limit, 1]), ones([app.band_limit, 1]),zeros([app.n/2-app.band_limit, 1])); 
        
        % Band Limited Signal used for Calculations
        app.filtered_signal = app.freq_y .* app.filter; 
        
        % Band Limited Signal used for plotting
        app.plot_filtered = app.fft_y .* app.plotting_filter; 
        app.UIAxes3.Visible  = 'on';

        % Plotting Filtered Signal Spectrum
        plot(app.UIAxes3,app.fshift, abs(app.plot_filtered)); 
        xlabel(app.UIAxes3,'Frequency (Hz)');
        ylabel(app.UIAxes3,'Filtered Signal');
        title(app.UIAxes3,'Filtered Signal Spectrum');
        clear plot_filtered plotting_filter;
    end
    %-----------------------------------%


    %%------------< EXP 3.3 >------------
    if app.counter == 2
    	% Getting filtered signal in time domain from frequency domain
        app.time_signal = ifftshift(app.filtered_signal);
        clear filtered_signal;
        app.time_signal = real(ifft(app.time_signal));
        app.t = linspace(0,app.n/app.Fs,app.n);
        app.UIAxes.Visible  = 'on';

        % Plotting the filtered signal in time domain
        plot(app.UIAxes,app.t, app.time_signal); %
        xlabel(app.UIAxes,'Time (seconds)');
        ylabel(app.UIAxes,'Filtered Signal');
        title(app.UIAxes,'Filtered signal band limited in time domain');
    end
     %-----------------------------------%
    

    %%------------< EXP 3.4 >------------
    if app.counter == 3
        app.Label_3.Text='Playing sound please wait.....';
        % Play filtered Signal
        sound(app.time_signal, app.Fs); 
        pause(8.5);
        app.Label_3.Text='';
    end
    %-----------------------------------%


    %%------------< EXP 3.5 >------------
    if app.counter == 4
        app.fc = 100000;

        % Resampling fs to 5fc
        app.m_t = resample(app.time_signal, 5*app.fc, app.Fs); 
        clear time_signal;
        app.n = length(app.m_t);
        app.fs_y = 5*app.fc;
        app.fshift = (app.fs_y/2) * linspace(-1, 1, app.fs_y);
        app.t = linspace(0,app.n/app.fs_y,app.n);
        
        % Creating Carrier signal
        app.c_t = cos(2*pi*app.fc*app.t)'; 
        
        % Assume Kf=1 ( Small because narrow band )
        kf = 1; 
        m_int=kf*2*pi*cumsum(app.m_t).';
        app.nbfm=cos(2*app.fc*pi*app.t + m_int);
        app.UIAxes2.Visible  = 'on';
        app.UIAxes3.Visible  = 'on';

        % Plotting the NBFM signal
        plot(app.UIAxes2,app.t,app.nbfm);
        title(app.UIAxes2,'NBFM Signal');
        xlabel(app.UIAxes2,'Time ( seconds )')
        ylabel(app.UIAxes2,'Amplitude ( Volt )')
        ylim(app.UIAxes2,[0 1.5]);

        F_nbfm = abs(fftshift(fft(app.nbfm, numel(app.fshift))));
        
        % Plotting the Spectrum of the NBFM
        plot(app.UIAxes3,app.fshift, F_nbfm);
        xlabel(app.UIAxes3,'Frequenct (Hz)');
        ylabel(app.UIAxes3,'NBFM');
        ylim(app.UIAxes3,[0 100000]);
        title(app.UIAxes3,'NBFM Spectrum');
    end
    %-----------------------------------%
     
     
     
    %%------------< EXP 3.6 >------------
    if app.counter == 5
    	am = [diff(app.nbfm) 0]./length(app.filtered_signal);
        envelope = abs(hilbert(am));
        app.UIAxes2.Visible  = 'on';
        app.UIAxes3.Visible  = 'on';
        % Plotting the differentiator output
        plot(app.UIAxes2,am);
        xlabel(app.UIAxes2,'Time ( seconds )')
        ylabel(app.UIAxes2,'Amplitude ( Volt )')
        title (app.UIAxes2,'Differentiator output before envelope'); 
        % Plotting the Demodulated NBFM signal with ED
        plot(app.UIAxes3,envelope);
        xlabel(app.UIAxes3,'Time ( seconds )')
        ylabel(app.UIAxes3,'Amplitude ( Volt )')
        title (app.UIAxes3,'Demodulated NBFM Signal with ED'); 
    end
end
