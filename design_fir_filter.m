function [b, fc] = design_fir_filter(N, type, f_signal, Fs)
% DESIGN_FIR_FILTER Belirtilen parametrelere göre bir FIR filtresi tasarlar.


    fn = Fs/2; % Nyquist frekansı
    order = N - 1; % Filtre derecesi

    % Agresif bir filtreleme için geçirme bandını çok dar tutuyoruz.
    % Örneğin, toplam 20 Hz'lik bir bant genişliği.
    passband_half_width_hz = 10; % Sinyal frekansının +/- 10 Hz'i

    switch type
        case 'LPF'
            % LPF'nin kesimini sinyalin hemen sağına koyuyoruz.
            fc = (f_signal + passband_half_width_hz) / fn;
            if fc >= 1, fc = 0.99; end
            b = fir1(order, fc, 'low', hamming(N));

        case 'HPF'
            % HPF'nin kesimini sinyalin hemen soluna koyuyoruz.
            fc = (f_signal - passband_half_width_hz) / fn;
            if fc <= 0, fc = 0.01; end
            b = fir1(order, fc, 'high', hamming(N));

        case 'BPF'
            % BPF için sinyali merkez alan çok dar bir bant oluşturuyoruz.
            fc1 = (f_signal - passband_half_width_hz) / fn;
            fc2 = (f_signal + passband_half_width_hz) / fn;
            fc = [fc1, fc2];
            
            if fc1 <= 0, fc1 = 0.01; end
            if fc2 >= 1, fc2 = 0.99; end
            
            b = fir1(order, [fc1, fc2], 'bandpass', hamming(N));
    end
end