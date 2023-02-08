function SSB(app)
    cla(app.UIAxes, 'reset');
    cla(app.UIAxes2, 'reset');
    cla(app.UIAxes3, 'reset');
    cla(app.UIAxes4, 'reset');
    cla(app.UIAxes5, 'reset');
    cla(app.UIAxes6, 'reset');
    app.UIAxes.Visible = 'off';
    app.UIAxes2.Visible = 'off';
    app.UIAxes3.Visible = 'off';
    app.UIAxes4.Visible = 'off';
    app.UIAxes5.Visible = 'off';
    app.UIAxes6.Visible = 'off';
    
    %%------------< EXP 2.1 >------------
    if app.counter == 1
        app.fvec = app.Fs / 2 * linspace(-1, 1, app.n);
        app.freq_y = fftshift(fft(app.y));
        app.fft_y = fftshift(fft(app.y, length(app.fvec)));

        % Plotting the Frequency Spectrum of Signal
        plot(app.UIAxes, app.fvec, abs(app.fft_y));
        xlabel(app.UIAxes, 'Frequency (Hz)');
        ylabel(app.UIAxes, 'M (f)');
        title(app.UIAxes, 'Signal Spectrum');
    end
    %-----------------------------------%


    %%------------< EXP 2.2 >------------
    if app.counter == 2
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.y, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 2.3 >------------
    if app.counter == 3
        % Using an ideal filter to remove all frequencies greater than 4 KHz
        app.filtered_signal = app.fft_y;
        app.filtered_signal(app.fvec >= 4000 | app.fvec <= -4000) = 0;

        % Plotting Filtered Signal Spectrum
        plot(app.UIAxes, app.fvec, abs(app.filtered_signal));
        xlabel(app.UIAxes, 'Frequency (Hz)');
        ylabel(app.UIAxes, 'M (f)');
        title(app.UIAxes, 'Filtered Signal Spectrum');
        clear plot_filtered app.plotting_filter;
    end
    %-----------------------------------%



    %%------------< EXP 2.4 >------------
    if app.counter == 4
        % Converting the signal back to time domain from frequency domain
        app.t = linspace(0, app.n / app.Fs, app.n);
        app.time_signal = real(ifft(ifftshift(app.filtered_signal)));

        % Plotting the filtered Signal in Time Domain
        plot(app.UIAxes, app.t, app.time_signal);
        xlabel(app.UIAxes, 'Time (seconds)');
        ylabel(app.UIAxes, 'm (t)');
        title(app.UIAxes, 'Filtered Signal in Time Domain');

        % Sound of Filtered Signal
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.time_signal, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 2.5 >------------
    if app.counter == 5
        app.fc = 100000;
        % Changing fs to 5fc
        app.m_t = resample(app.time_signal, 5 * app.fc, app.Fs);
        clear app.time_signal;
        app.n = length(app.m_t);
        app.fs_y = 5 * app.fc;

        % Vectors for defining time and frequency axis
        app.t = linspace(0, app.n / (5 * app.fc), app.n);
        app.fshift = (app.fs_y / 2) * linspace(-1, 1, app.fs_y);

        % Creating carrier signal
        app.c_t = cos(2 * pi * app.fc * app.t)';

        % Getting DSB-SC signal
        app.DSB_SC = app.m_t .* app.c_t;
        app.F_DSB_SC = abs(fftshift(fft(app.DSB_SC, length(app.fshift))));

	% Plotting DSB-SC
        plot(app.UIAxes2, app.fshift, app.F_DSB_SC);
        xlabel(app.UIAxes2, 'Frequency (Hz)');
        ylabel(app.UIAxes2, 'DSB-SC');
        title(app.UIAxes2, 'DSB-SC Spectrum');
        xlim(app.UIAxes2, [-app.fc - 8000 app.fc + 8000]);
        ylim(app.UIAxes2, [0 1500]);

        % Changing amplitude of carrier to double max of message
        app.Ac = 2 * max(app.m_t);

        % Getting DSB-TC signal 
        app.DSB_TC = (app.Ac + app.m_t) .* app.c_t;
        app.F_DSB_TC = abs(fftshift(fft(app.DSB_TC, length(app.fshift))));
        
        % Plotting DSB-TC
        plot(app.UIAxes3, app.fshift, app.F_DSB_TC);
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, 'DSB-TC');
        title(app.UIAxes3, 'DSB-TC Spectrum');
        xlim(app.UIAxes3, [-app.fc - 8000 app.fc + 8000]);
        ylim(app.UIAxes3, [0 1500]);
    end
    %-----------------------------------%


    %%------------< EXP 2.6 >------------
    if app.counter == 6
        app.L = length(app.DSB_SC);
        app.freq = app.fs_y / 2 * linspace(-1, 1, app.L);

        % Getting SSB-SC signal using ideal filter
        app.SSB_f = fftshift(fft(app.DSB_SC, length(app.freq)));

        % unit step function implementation
        app.SSB_f(app.freq >= app.fc | app.freq <= -app.fc) = 0;
        app.SSB_t = ifft(ifftshift(app.SSB_f));
        
        % Plotting SSB modulated Signal Spectrum
        plot(app.UIAxes, app.freq, abs(app.SSB_f));
        title(app.UIAxes, 'SSB Modulated Signal Spectrum');
        xlim(app.UIAxes, [-app.fc - 8000 app.fc + 8000]);
        ylim(app.UIAxes, [0 1500]);
    end
    %-----------------------------------%


    %%------------< EXP 2.7 >------------
    if app.counter == 7

        % Demodulating SSB-SC signal using coherent detection
        app.Demodulated_SSB_t = app.SSB_t .* app.c_t;
        app.Demodulated_SSB_f = fftshift(fft(app.Demodulated_SSB_t));
        app.L = length(app.Demodulated_SSB_t);
        app.freq = app.fs_y / 2 * linspace(-1, 1, app.L);
        app.Demodulated_SSB_f(app.freq >= 4000 | app.freq <= -4000) = 0;
        
        % Getting demodulated SSB-SC signal in time domain
        app.Demodulated_SSB_t = 4 * real(ifft(ifftshift(app.Demodulated_SSB_f)));
        plot(app.UIAxes2, app.t, app.Demodulated_SSB_t);
        title(app.UIAxes2, 'SSB Demodulated Signal in Time Domain');
        plot(app.UIAxes3, app.freq, abs(app.Demodulated_SSB_f));
        title(app.UIAxes3, 'SSB Demodulated Signal Spectrum');
        xlim(app.UIAxes3, [-app.fc - 8000 app.fc + 8000]);
        ylim(app.UIAxes3, [0 1500]);
        app.Demodulated_SSB_t = resample(app.Demodulated_SSB_t, app.Fs, 5 * app.fc);

        % Playing demodulated SSB-SC signal
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.Demodulated_SSB_t, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
     %-----------------------------------%



    %%------------< EXP 2.8 >------------
    if app.counter == 8

        % Using a butterworth filter of order 4 to filter DSB-SC signal to SSB-SC
        [app.b, app.a] = butter(4, app.fc / (app.fs_y / 2));
        app.SSB_practical_t = filter(app.b, app.a, app.DSB_SC);
        app.freq = app.fs_y / 2 * linspace(-1, 1, length(app.DSB_SC));

        plot(app.UIAxes4, app.freq, abs(fftshift(fft(app.SSB_practical_t, length(app.freq)))));
        xlabel(app.UIAxes4, 'Frequency (Hz)');
        ylabel(app.UIAxes4, 'Magnitude');
        title(app.UIAxes4, 'SSB-SC Filtered - Butterworth Filter');

        % Demodulating signal and obtaining spectrum
        app.Demod_SSB_butter_t = app.SSB_practical_t .* app.c_t;
        [app.b, app.a] = butter(4, 4000 / (app.fs_y / 2));

        % Getting demodulated SSB-SC signal in time and frequency domains
        app.Demod_SSB_butter_t = filter(app.b, app.a, app.Demod_SSB_butter_t);
        app.Demod_SSB_butter_f = fftshift(fft(app.Demod_SSB_butter_t));
        
        % Plotting the Waveform and Spectrum of SSB Demodulated Butterworth-filtered
        plot(app.UIAxes5, app.t, app.Demod_SSB_butter_t);
        title(app.UIAxes5, 'SSB Demodulated Signal Waveform - Butterworth Filter');
        xlabel(app.UIAxes5, 'Time (seconds)');
        ylabel(app.UIAxes5, 'm(t)');

        plot(app.UIAxes6, app.freq, abs(app.Demod_SSB_butter_f));
        title(app.UIAxes6, 'SSB Demodulated Signal Spectrum - Butterworth Filter');
        xlabel(app.UIAxes6, 'Frequency (Hz)');
        ylabel(app.UIAxes6, '|M(f)|');
        
	% Playing Signal after butterworth filter
        app.Demod_SSB_butter_t = resample(app.Demod_SSB_butter_t, app.Fs, 5 * app.fc);
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.Demod_SSB_butter_t, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 2.9 >------------
    %%--- (SSB-SC, SNR = 0) ---
    if app.counter == 9
        % Adding white gaussian noise to signal
        app.SSB_SNR0 = awgn(app.SSB_t, 0);

        % Demodulating noisy signal and obtaining spectrum
        app.demod_t_SNR0 = app.SSB_SNR0 .* app.c_t;
        app.demod_f_SNR0 = fftshift(fft(app.demod_t_SNR0));

        % Getting noisy signal in Time Domain
        app.demod_f_SNR0(app.freq >= 4000 | app.freq <= -4000) = 0;
        app.demod_t_SNR0 = 4 * real(ifft(ifftshift(app.demod_f_SNR0)));

        % Plotting the SSB Demodulated signal SNR = 0 in Time and frequency Domain and Spectrum
        plot(app.UIAxes2, app.t, app.demod_t_SNR0);
        title(app.UIAxes2, 'SSB Demodulated Signal Waveform (Time Domain) [SNR = 0]');
        xlabel(app.UIAxes2, 'Time (seconds)');
        ylabel(app.UIAxes2, 'm(t)');

        plot(app.UIAxes3, app.freq, abs(app.demod_f_SNR0));
        title(app.UIAxes3, 'SSB Demodulated Signal Spectrum (Frequency Domain) [SNR = 0]');
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, '|M (f)|');


	% Playing Noisy Signal
        app.demod_t_SNR0 = resample(app.demod_t_SNR0, app.Fs, 5 * app.fc);
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.demod_t_SNR0, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 2.10 >------------
    %%--- (SSB-SC, SNR = 10) ---
    if app.counter == 10
        % Adding white gaussian noise to signal
        app.SSB_SNR10 = awgn(app.SSB_t, 10);

        % Demodulating noisy signal and obtaining spectrum
        app.demod_t_SNR10 = app.SSB_SNR10 .* app.c_t;
        app.demod_f_SNR10 = fftshift(fft(app.demod_t_SNR10));

        % Getting noisy signal in Time Domain
        app.demod_f_SNR10(app.freq >= 4000 | app.freq <= -4000) = 0;
        app.demod_t_SNR10 = 4 * real(ifft(ifftshift(app.demod_f_SNR10)));

        % Plotting the SSB Demodulated signal SNR = 10 in Time and frequency Domain and Spectrum
        plot(app.UIAxes2, app.t, app.demod_t_SNR10);
        title(app.UIAxes2, 'SSB Demodulated Signal Waveform (Time Domain) [SNR = 10]');
        xlabel(app.UIAxes2, 'Time (seconds)');
        ylabel(app.UIAxes2, 'm(t)');

        plot(app.UIAxes3, app.freq, abs(app.demod_f_SNR10));
        title(app.UIAxes3, 'SSB Demodulated Signal Spectrum (Frequency Domain) [SNR = 10]');
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, '|M(f)|');
	
	
	% Playing Noisy Signal
        app.demod_t_SNR10 = resample(app.demod_t_SNR10, app.Fs, 5 * app.fc);
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.demod_t_SNR10, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 2.11 >------------
    %%--- (SSB-SC, SNR = 30) ---
    if app.counter == 11
        % Adding white gaussian noise to signal
        app.SSB_SNR30 = awgn(app.SSB_t, 30);

        % Demodulating noisy signal and obtaining spectrum
        app.demod_t_SNR30 = app.SSB_SNR30 .* app.c_t;
        app.demod_f_SNR30 = fftshift(fft(app.demod_t_SNR30));

        % Getting noisy signal
        app.demod_f_SNR30(app.freq >= 4000 | app.freq <= -4000) = 0;
        app.demod_t_SNR30 = 4 * real(ifft(ifftshift(app.demod_f_SNR30)));

        % Plotting the SSB Demodulated signal SNR = 30 in Time and frequency Domain and Spectrum
        plot(app.UIAxes2, app.t, app.demod_t_SNR30);
        title(app.UIAxes2, 'SSB Demodulated Signal Waveform (Time Domain) [SNR = 30]');
        xlabel(app.UIAxes2, 'Time (seconds)');
        ylabel(app.UIAxes2, 'm(t)');
        plot(app.UIAxes3, app.freq, abs(app.demod_f_SNR30));
        title(app.UIAxes3, 'SSB Demodulated Signal Spectrum (Frequency Domain) [SNR = 30]');
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, '|M(f)|');


	% Playing Noisy Signal
        app.demod_t_SNR30 = resample(app.demod_t_SNR30, app.Fs, 5 * app.fc);
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.demod_t_SNR30, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 2.12 >------------
    if app.counter == 12
        % obtaining SSB-TC signal
        app.SSB_t = real(app.SSB_t);
        app.SSB_t_TC = app.Ac .* app.c_t + app.SSB_t;
        app.envelopeSSB_TC = abs(hilbert(app.SSB_t_TC));
        app.envelopeSSB_TC = app.envelopeSSB_TC - mean(app.envelopeSSB_TC);
        % Using Double the amplitude
        app.envelopeSSB_TC = 2 * app.envelopeSSB_TC;

        % Plotting envelope of SSB-SC
        plot(app.UIAxes, app.t, app.envelopeSSB_TC);
        title(app.UIAxes, 'Envelope of the SSB-TC');
        xlabel(app.UIAxes, 'Time (seconds)');
        ylabel(app.UIAxes, 'm(t)');

        % Resampling back to Fs to play the Signal
        app.envelopeSSB_TC = resample(app.envelopeSSB_TC, app.Fs, 5 * app.fc);
        % Playing the audio of the SSB-TC 
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.envelopeSSB_TC, app.Fs); 
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%
end
