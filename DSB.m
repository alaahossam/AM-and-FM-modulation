function DSB(app)
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

    %%------------< EXP 1.1 >------------
    if app.counter == 1
        app.fs_y = app.n / app.ty;
        app.fshift = (app.fs_y / 2) * linspace(-1, 1, app.fs_y);
        app.freq_y = fftshift(fft(app.y));
        app.fft_y = fftshift(fft(app.y, numel(app.fshift)));

        % Plotting the spectrum of the audio signal
        plot(app.UIAxes, app.fshift, abs(app.fft_y));
        xlabel(app.UIAxes, 'Frequency (Hz)');
        ylabel(app.UIAxes, 'M(f)');
        title(app.UIAxes, 'Audio Signal Spectrum');
    end
    %-----------------------------------%


    %%------------< EXP 1.2 >------------
    if app.counter == 2
    	% Get bandlimit from our Signal to remove unwanted frequencies
        app.band_limit = floor(app.fn + app.ty);
        app.plotting_filter = cat(1, zeros([app.Fs / 2 - 4e3, 1]), ones([4e3, 1]), ones([4e3, 1]), zeros([app.Fs / 2 - 4e3, 1]));
        %ideal filter from 0 to 4KHz
        app.filter = cat(1, zeros([app.n / 2 - app.band_limit, 1]), ones([app.band_limit, 1]), ones([app.band_limit, 1]), zeros([app.n / 2 - app.band_limit, 1])); 
        
        % the actual signal used for sound
        app.filtered_signal = app.freq_y .* app.filter; 
        
        % Filtered signal used for plotting
        app.plot_filtered = app.fft_y .* app.plotting_filter; 

        % Plotting the filtered signal spectrum
        plot(app.UIAxes, app.fshift, abs(app.plot_filtered)); 
        xlabel(app.UIAxes, 'Frequency (Hz)');
        ylabel(app.UIAxes, 'M(f)');
        title(app.UIAxes, 'Filtered Signal Spectrum');
        clear app.plot_filtered app.plotting_filter;
    end
    %-----------------------------------%


    %%------------< EXP 1.3 >------------
    if app.counter == 3
        app.time_signal = ifftshift(app.filtered_signal);
        clear app.filtered_signal;
        app.time_signal = real(ifft(app.time_signal));
        app.t = linspace(0, app.n / app.Fs, app.n);

        % Plotting the filtered signal in time domain
        plot(app.UIAxes, app.t, app.time_signal); 
        xlabel(app.UIAxes, 'Time (seconds)');
        ylabel(app.UIAxes, 'm(t)');
        title(app.UIAxes, 'Filtered Signal');
    end
    %-----------------------------------%


    %%------------< EXP 1.4 >------------
    if app.counter == 4
    	% Sound of the filtered signal of BW=4KHz Which is not different from the original by much
        app.Label_3.Text = 'Playing sound please wait.....';
        sound(app.time_signal, app.Fs); 
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%


    %%------------< EXP 1.5 >------------
    if app.counter == 5
        app.fc = 1e5;
        
        % Resample fs to 5fc
        app.m_t = resample(app.time_signal, 5 * app.fc, app.Fs); 
        clear app.time_signal;
        % Get new length of signal
        app.n = length(app.m_t);
        % Get new time line and frequency
        app.ty = app.n / (5 * app.fc);
        app.fs_y = app.n / app.ty;
        app.fshift = (app.fs_y / 2) * linspace(-1, 1, app.fs_y);
        app.t = linspace(0, app.n / (5 * app.fc), app.n);
        
        % Create Carrier signal
        app.c_t = cos(2 * pi * app.fc * app.t)'; 
        % Create DSB-SC signal
        app.DSB_SC = app.m_t .* app.c_t; 
        app.F_DSB_SC = abs(fftshift(fft(app.DSB_SC, numel(app.fshift))));

        % Plotting the DSB-SC signal spectrum 
        plot(app.UIAxes2, app.fshift, app.F_DSB_SC); 
        xlabel(app.UIAxes2, 'Frequency (Hz)');
        ylabel(app.UIAxes2, 'DSB-SC');
        title(app.UIAxes2, 'Spectrum of the DSB-SC');
        xlim(app.UIAxes2, [-app.fc - 8e3 app.fc + 8e3]); 
        ylim(app.UIAxes2, [0 1500]);

        % Changing the carrier frequency to be double the maximum of the message
        app.Ac = 2 * max(app.m_t); 
        app.DSB_TC = (app.Ac + app.m_t) .* app.c_t;
        app.F_DSB_TC = abs(fftshift(fft(app.DSB_TC, numel(app.fshift))));

        % Plotting the DSB-TC signal spectrum
        plot(app.UIAxes3, app.fshift, app.F_DSB_TC); 
        clear app.F_DSB_TC app.F_DSB_SC;
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, 'DSB-TC');
        title(app.UIAxes3, 'Spectrum of the DSB-TC');
        xlim(app.UIAxes3, [-app.fc - 8e3 app.fc + 8e3]);
        ylim(app.UIAxes3, [0 1500]);
    end
    %-----------------------------------%
    

    %%------------< EXP 1.6 >------------
    if app.counter == 6
    	% Getting the envelope of DSB-SC
        app.env_DSB_SC = abs(hilbert(app.DSB_SC));

        % Plotting the envelope of the DSB-SC
        plot(app.UIAxes2, app.t, app.env_DSB_SC); 
        xlabel(app.UIAxes2, 'Time (seconds)');
        ylabel(app.UIAxes2, 'DSB-SC');
        title(app.UIAxes2, 'Envelope of the DSB-SC');
        app.Label_3.Text = 'Playing sound please wait.....';
        
        % resampling back to Fs to play the signal
        app.env_DSB_SC = resample(app.env_DSB_SC, app.Fs, 5 * app.fc); 
        
        % Sound of the DSB-SC after envelope
        sound(app.env_DSB_SC, app.Fs); 
        pause(8.5);
        
        % Getting the envelope of DSB-TC
        app.env_DSB_TC = abs(hilbert(app.DSB_TC));
        app.env_DSB_TC = app.env_DSB_TC - mean(app.env_DSB_TC);

        % Plotting the envelope of the DSB-TC
        plot(app.UIAxes3, app.t, app.env_DSB_TC); 
        xlabel(app.UIAxes3, 'Time (seconds)');
        ylabel(app.UIAxes3, 'DSB-TC');
        title(app.UIAxes3, 'Envelope of the DSB-TC');

        % resampling back to Fs to play the signal
        app.env_DSB_TC = resample(app.env_DSB_TC, app.Fs, 5 * app.fc); 
        
        % Sound of the DSB-TC after envelope
        sound(app.env_DSB_TC, app.Fs); 
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%
    
    

    %%------------< EXP 1.7 >------------
    if app.counter == 7
    	% Create vector for each SNR in db
        app.db_vec = [0, 10, 30]; 
        % Adding guassian distributed noise using awgn ( from Communication Toolbox )
        app.out_db(:, 1) = awgn(app.DSB_SC, app.db_vec(1), 'measured'); 
    	% Vector for output
        app.out_db = zeros(length(app.DSB_SC), 3); 
        % Vector for demodulated signal in time domain
        app.demodulated = zeros(length(app.DSB_SC), 3); 
        % Vector for demodulated signal in frequency domain
        app.demod_freq_domain = zeros(5 * app.fc, 3); 
		app.Label_3.Text = 'Resampling takes time please wait.....';
        for i = 1:3
            cla(app.UIAxes3, 'reset');
            cla(app.UIAxes2, 'reset');

            % Adding noise to DSB-SC signal
            app.out_db(:, i) = awgn(app.DSB_SC, app.db_vec(i), 'measured'); 
            
            % Coherent detection
            app.demodulated(:, i) = app.out_db(:, i) .* app.c_t; 

            % Plotting detected signal in time domain
            plot(app.UIAxes2, app.t, app.demodulated(:, i)); 
            xlabel(app.UIAxes2, 'Time (seconds)');
            ylabel(app.UIAxes2, sprintf('Output of %ddb', app.db_vec(i)));
            title(app.UIAxes2, sprintf('DSB-SC with SNR of %ddbin time domain', app.db_vec(i)));
            
            % Getting signal in the frequency domain
            app.demod_freq_domain(:, i) = abs(fftshift(fft(app.demodulated(:, i), numel(app.fshift))));

            % Plotting detected signal in frequency domain
            plot(app.UIAxes3, app.fshift, app.demod_freq_domain(:, i)); 
            xlim(app.UIAxes3, [-app.band_limit - 1e3 app.band_limit + 1e3]);
            xlabel(app.UIAxes3, 'Frequency (Hz)');
            ylabel(app.UIAxes3, sprintf('Output of %ddb', app.db_vec(i)));
            title(app.UIAxes3, sprintf('DSB-SC with SNR of %ddbin frequency domain', app.db_vec(i)));
            pause(8.5);
        end
	app.Label_3.Text = 'Playing sound SNR of 0db please wait.....';
        % Resampling to sound the 3 signals
        app.s1 = resample(app.demodulated(:, 1), app.Fs, 5 * app.fc);
        app.s2 = resample(app.demodulated(:, 2), app.Fs, 5 * app.fc);
        app.s3 = resample(app.demodulated(:, 3), app.Fs, 5 * app.fc);

        % Playing the sounds one after another while waiting for them to finish
        sound(app.s1, app.Fs);
        pause(8.5);
        app.Label_3.Text = 'Playing sound SNR of 10db please wait.....';
        sound(app.s2, app.Fs);
        pause(8.5);
        app.Label_3.Text = 'Playing sound SNR of 30db please wait.....';
        sound(app.s3, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
        clear app.s1 app.s2 app.s3 app.out_db app.demodulated app.demod_freq_domain;
    end
    %-----------------------------------%


    %%------------< EXP 1.8 >------------
    if app.counter == 8

        % Adding frequency error
        app.fc_error = app.fc + 0.1 * 1e3; 
        
        % Applying the frequency error
        app.c_t_freq_error = cos(2 * pi * app.fc_error * app.t)'; 
        
        % Coherent detection with frequency error
        app.demodulated_with_freq_error = app.DSB_SC .* app.c_t_freq_error;

        % Plotting the signal time domain
        plot(app.UIAxes2, app.t, app.demodulated_with_freq_error); 
        xlabel(app.UIAxes2, 'Time (seconds)');
        ylabel(app.UIAxes2, 'm(t)');
        title(app.UIAxes2, 'Demodulation with frequency error at the carrier');
        app.freq_error = abs(fftshift(fft(app.demodulated_with_freq_error, numel(app.fshift))));

        % Plotting the spectrum of the signal
        plot(app.UIAxes3, app.fshift, app.freq_error); 
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, 'M(f)');
        title(app.UIAxes3, 'Demodulation with frequency error at the carrier');
        xlim(app.UIAxes3, [-app.band_limit - 1e3 app.band_limit + 1e3]);
        app.Label_3.Text = 'Playing sound please wait.....';
        app.s1 = resample(app.demodulated_with_freq_error, app.Fs, 5 * app.fc);
        sound(app.s1, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%
    
    
    %%------------< EXP 1.9 >------------
    if app.counter == 9
	% Defining the phase error
	phase_error = pi/9;
	
        % Applying the Phase error
        carrier_with_error = cos(2 * pi * app.fc * app.t +  pi/9)'; 
        
        % Coherent detection with Phase error
        detected_with_error = app.DSB_SC .* carrier_with_error;

        % Plotting the signal time domain
        plot(app.UIAxes2, app.t, detected_with_error); 
        xlabel(app.UIAxes2, 'Time (seconds)');
        ylabel(app.UIAxes2, 'm(t)');
        title(app.UIAxes2, 'Demodulation with Phase error at the carrier');
        phase_error = abs(fftshift(fft(detected_with_error, numel(app.fshift))));

        % Plotting the spectrum of the signal
        plot(app.UIAxes3, app.fshift, phase_error); 
        xlabel(app.UIAxes3, 'Frequency (Hz)');
        ylabel(app.UIAxes3, 'M(f)');
        title(app.UIAxes3, 'Demodulation with Phase error at the carrier');
        xlim(app.UIAxes3, [-app.band_limit - 1e3 app.band_limit + 1e3]);
        app.Label_3.Text = 'Playing sound please wait.....';
        app.s1 = resample(detected_with_error, app.Fs, 5 * app.fc);
        sound(app.s1, app.Fs);
        pause(8.5);
        app.Label_3.Text = '';
    end
    %-----------------------------------%
end




