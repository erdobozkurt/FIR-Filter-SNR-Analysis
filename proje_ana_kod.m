%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ELE-306 Sayısal İşaret İşleme Projesi
% Grup No: 22
% Konu: FIR Filtrelerle SNR İyileştirme ve Filtre Uzunluğu Etkisi Analizi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Temel Parametrelerin Tanımlanması
clear; clc; close all;

% --- Grup 22 Parametreleri ---
f_signal = 2917;  % Sinyal frekansı [Hz]
Fs = 8000;        % Örnekleme frekansı [Hz]
A = 1;            % Sinyal genliği

% --- Simülasyon Parametreleri ---
duration = 1;     % Sinyal süresi [s]
t = 0:1/Fs:duration-1/Fs; % Zaman vektörü
N_samples = length(t);    % Örnek sayısı
target_snr_db = 30;       % Hedef çıkış SNR [dB] 
initial_snr_db = [-6, 0, 6]; % Giriş SNR seviyeleri [dB] 
noise_types = {'white', 'pink', 'blue'};
filter_types = {'LPF', 'HPF', 'BPF'};

% --- Sonuçları Saklamak İçin Yapı ---
results = struct();

%% Adım 1: Orijinal Sinyalin Üretilmesi
original_signal = A * cos(2 * pi * f_signal * t); % 
signal_power = bandpower(original_signal);

fprintf('--- Proje Başlatıldı: Grup 22 (f=%d Hz, Fs=%d Hz) ---\n', f_signal, Fs);

%% Adım 2: Sinyal ve Gürültü Üretimi & Filtreleme Döngüsü
% Bu ana döngü, her bir gürültü, SNR ve filtre tipi kombinasyonu için çalışır.
for i = 1:length(noise_types)
    noise_type = noise_types{i};
    
    for j = 1:length(initial_snr_db)
        snr_in_db = initial_snr_db(j);
        
        % --- Gürültünün Üretilmesi ve SNR'ın Ayarlanması ---
        noise_power_target = signal_power / (10^(snr_in_db / 10)); % 
        
        switch noise_type
            case 'white'
                noise_gen = wgn(1, N_samples, 0);
            case 'pink'
                noise_gen = pinknoise(N_samples);
            case 'blue'
                noise_gen = bluenoise(N_samples);
        end
        
        noise_gen = noise_gen * sqrt(noise_power_target / bandpower(noise_gen));
        noisy_signal = original_signal + noise_gen; % 
        calculated_snr_in = 10 * log10(bandpower(original_signal) / bandpower(noisy_signal - original_signal));
        
        fprintf('\n>> Analiz: Gürültü=%s, Giriş SNR=%.1f dB\n', noise_type, snr_in_db);
        
        for k = 1:length(filter_types)
            filter_type = filter_types{k};
            
            % --- Adım 3: Nmin (Minimum Filtre Uzunluğu) Bulma ---
            fprintf('   -> Filtre=%s: Hedef SNR (30 dB) için N_min aranıyor...\n', filter_type);
            
            N = 11; 
            snr_out_db = -inf;
            max_achieved_snr = -inf;
            N_for_max_snr = N;
            
            while snr_out_db < target_snr_db && N <= 6000 % Max deneme uzunluğu
                N = N + 2; 
                
                % Filtre tasarımı
                [b, ~] = design_fir_filter(N, filter_type, f_signal, Fs);
                
                
                % Temiz sinyali ve gürültüyü ayrı ayrı filtrele
                signal_component_out = filter(b, 1, original_signal);
                noise_component_out = filter(b, 1, noise_gen);
                
                % Geçici durumdan sonraki güçleri hesapla
                power_s_out = bandpower(signal_component_out(N:end));
                power_v_out = bandpower(noise_component_out(N:end));
                
                if power_v_out < 1e-12, power_v_out = 1e-12; end % Sıfıra bölmeyi engelle
                
                snr_out_db = 10 * log10(power_s_out / power_v_out);
                
                if snr_out_db > max_achieved_snr
                    max_achieved_snr = snr_out_db;
                    N_for_max_snr = N;
                end
            end
            
            if snr_out_db >= target_snr_db
                N_min = N;
                fprintf('      ... bulundu! N_min = %d, Çıkış SNR = %.2f dB\n', N_min, snr_out_db);
            else
                N_min = N_for_max_snr;
                fprintf('      ... 30 dB hedefine ulaşılamadı. Max SNR = %.2f dB (N=%d ile)\n', max_achieved_snr, N_min);
            end
            
            results.(noise_type)(j).(filter_type).N_min = N_min;
            results.(noise_type)(j).(filter_type).max_snr = max_achieved_snr;
            
            % --- Adım 4: Farklı Uzunluklar İçin Analiz --- %
            filter_lengths_to_analyze = unique([N_min, round(1.5*N_min), round(2*N_min)]);
            
            for l = 1:length(filter_lengths_to_analyze)
                current_N = filter_lengths_to_analyze(l);
                if mod(current_N, 2) == 0, current_N = current_N + 1; end
                
                [b, ~] = design_fir_filter(current_N, filter_type, f_signal, Fs);
                
                
                signal_component_out = filter(b, 1, original_signal);
                noise_component_out = filter(b, 1, noise_gen);
                
                power_s_out = bandpower(signal_component_out(current_N:end));
                power_v_out = bandpower(noise_component_out(current_N:end));
                if power_v_out < 1e-12, power_v_out = 1e-12; end
                
                snr_out_final = 10*log10(power_s_out / power_v_out);
                snr_improvement = snr_out_final - calculated_snr_in;
                
                results.(noise_type)(j).(filter_type).analysis(l).N = current_N;
                results.(noise_type)(j).(filter_type).analysis(l).coeffs = b;
                results.(noise_type)(j).(filter_type).analysis(l).snr_out = snr_out_final;
                results.(noise_type)(j).(filter_type).analysis(l).snr_improvement = snr_improvement;
                results.(noise_type)(j).(filter_type).analysis(l).complexity_mults = current_N;
                results.(noise_type)(j).(filter_type).analysis(l).complexity_adds = current_N - 1;
            end
        end
    end
end
fprintf('\n--- Tüm Analizler Tamamlandı ---\n\n');


%% Adım 5: Sonuçların Raporlanması ve Görselleştirilmesi
fprintf('\n\n--- PROJE SONUÇ ÖZETİ ---\n\n');

% 1. Sonuçların Özet Tablosunu Komut Ekranına Yazdır
% Bu tablo, raporun "Tablo 5.1" bölümünü doldurmak için kullanılabilir.
fprintf('%-15s | %-12s | %-12s | %-10s | %-18s | %-15s\n', ...
    'Gürültü Türü', 'Giriş SNR', 'Filtre Türü', 'N_min', 'Maks. Çıkış SNR', 'Hedefe Ulaşıldı?');
fprintf(repmat('-', 1, 95));
fprintf('\n');

for i = 1:length(noise_types)
    noise_type = noise_types{i};
    for j = 1:length(initial_snr_db)
        snr_in_db = initial_snr_db(j);
        for k = 1:length(filter_types)
            filter_type = filter_types{k};
            
            res = results.(noise_type)(j).(filter_type);
            N_min_val = res.N_min;
            max_snr_val = res.max_snr;
            
            if max_snr_val >= target_snr_db
                ulasildi_str = 'Evet';
            else
                ulasildi_str = 'Hayir';
            end
            
            fprintf('%-15s | %-12.1f | %-12s | %-10d | %-18.2f | %-15s\n', ...
                noise_type, snr_in_db, filter_type, N_min_val, max_snr_val, ulasildi_str);
        end
    end
end
fprintf('\n--- ÖZET TABLOSU SONU ---\n\n');


disp('--- Rapor İçin Karşılaştırmalı Grafikler Üretiliyor ---');

%% GRAFİK 1: FİLTRE TÜRÜ PERFORMANS KARŞILAŞTIRMASI
% Sabit bir gürültü ve SNR için LPF, HPF ve BPF'nin performansını karşılaştırır.
% Bu grafik, BPF'nin neden üstün olduğunu görsel olarak kanıtlar.
figure('Name', 'Filtre Türü Karşılaştırması (Pembe Gürültü, 0 dB)');
hold on;
grid on;
title('Filtre Türü Performans Karşılaştırması (Pembe Gürültü, Giriş SNR = 0 dB)');
xlabel('Filtre Uzunluğu (N)');
ylabel('Çıkış SNR (dB)');

% Analiz için gürültü sinyalini yeniden oluştur
noise_type_plot = 'pink';
snr_in_plot = 0;
noise_power_target = signal_power / (10^(snr_in_plot / 10));
noise_gen_plot = pinknoise(N_samples);
noise_gen_plot = noise_gen_plot * sqrt(noise_power_target / bandpower(noise_gen_plot));

N_range = 11:50:4001; 
line_styles = {'-', '--', ':'};
colors = {'r', 'g', 'b'};

for i = 1:length(filter_types)
    filter_type = filter_types{i};
    snr_vs_N = zeros(size(N_range));
    for j = 1:length(N_range)
        N_current = N_range(j);
        [b, ~] = design_fir_filter(N_current, filter_type, f_signal, Fs);
        
        s_out = filter(b, 1, original_signal);
        n_out = filter(b, 1, noise_gen_plot);
        
        power_s = bandpower(s_out(N_current:end));
        power_n = bandpower(n_out(N_current:end));
        if power_n < 1e-12, power_n = 1e-12; end
        snr_vs_N(j) = 10 * log10(power_s / power_n);
    end
    plot(N_range, snr_vs_N, 'DisplayName', filter_type, 'LineWidth', 2, ...
        'LineStyle', line_styles{i}, 'Color', colors{i});
end
yline(30, '--k', 'Hedef SNR', 'LineWidth', 1);
legend show;
hold off;


%% GRAFİK 2: GÜRÜLTÜ TÜRÜ PERFORMANS KARŞILAŞTIRMASI
% En iyi filtre (BPF) için farklı gürültü türlerine karşı performansı karşılaştırır.
% Bu grafik, filtrenin pembe gürültüde neden daha başarılı olduğunu gösterir.
figure('Name', 'Gürültü Türü Karşılaştırması (BPF Filtre, 6 dB)');
hold on;
grid on;
title('BPF Filtre Performansı (Farklı Gürültü Türleri, Giriş SNR = 6 dB)');
xlabel('Filtre Uzunluğu (N)');
ylabel('Çıkış SNR (dB)');

snr_in_plot = 6;
filter_type_plot = 'BPF';
N_range = 11:50:2001;

for i = 1:length(noise_types)
    noise_type = noise_types{i};
    
    % Gürültüyü üret
    noise_power_target = signal_power / (10^(snr_in_plot / 10));
    switch noise_type
        case 'white', noise_gen_plot = wgn(1, N_samples, 0);
        case 'pink',  noise_gen_plot = pinknoise(N_samples);
        case 'blue',  noise_gen_plot = bluenoise(N_samples);
    end
    noise_gen_plot = noise_gen_plot * sqrt(noise_power_target / bandpower(noise_gen_plot));
    
    snr_vs_N = zeros(size(N_range));
    for j = 1:length(N_range)
        N_current = N_range(j);
        [b, ~] = design_fir_filter(N_current, filter_type_plot, f_signal, Fs);
        
        s_out = filter(b, 1, original_signal);
        n_out = filter(b, 1, noise_gen_plot);
        
        power_s = bandpower(s_out(N_current:end));
        power_n = bandpower(n_out(N_current:end));
        if power_n < 1e-12, power_n = 1e-12; end
        snr_vs_N(j) = 10 * log10(power_s / power_n);
    end
    plot(N_range, snr_vs_N, 'DisplayName', sprintf('%s Gürültü', noise_type), ...
        'LineWidth', 2, 'LineStyle', line_styles{i});
end
yline(30, '--k', 'Hedef SNR', 'LineWidth', 1);
legend show;
hold off;


%% GRAFİK 3: FREKANS YANITI ANALİZİ ("İYİ" vs "KÖTÜ" FİLTRE)
% Başarılı bir filtre (BPF) ile başarısız bir filtrenin (LPF) frekans yanıtını karşılaştırır.
% Bu grafik, LPF'nin mavi gürültüde neden başarısız olduğunu görsel olarak açıklar.
figure('Name', 'İyi vs Kötü Filtre Frekans Yanıtı');
hold on;
grid on;
title('Frekans Yanıtı Karşılaştırması');
xlabel('Frekans (Hz)');
ylabel('Kazanç (dB)');

% İyi Filtre: BPF (Pembe Gürültü, N=109)
[b_good, ~] = design_fir_filter(109, 'BPF', f_signal, Fs);
[h_good, w] = freqz(b_good, 1, 4096, Fs);
plot(w, 20*log10(abs(h_good)), 'b', 'LineWidth', 2, 'DisplayName', 'İyi Filtre (BPF, N=109)');

% Kötü Filtre: LPF (Mavi Gürültü, N=111 - karşılaştırma için benzer uzunluk)
[b_bad, ~] = design_fir_filter(111, 'LPF', f_signal, Fs);
[h_bad, w] = freqz(b_bad, 1, 4096, Fs);
plot(w, 20*log10(abs(h_bad)), 'r--', 'LineWidth', 2, 'DisplayName', 'Kötü Filtre (LPF, N=111)');

xline(f_signal, ':k', 'Sinyal Frekansı (2917 Hz)');
ylim([-100, 5]);
legend show;
hold off;

%% GRAFİK 4: GEÇİCİ DURUM YANITI
% Rapor için temsili bir geçici durum yanıtı grafiği.
N_transient_example = 305; % Pembe gürültüde hedefe ulaşan N_min'lerden biri
[b_transient, ~] = design_fir_filter(N_transient_example, 'BPF', f_signal, Fs);
filtered_clean_signal = filter(b_transient, 1, original_signal);

figure('Name', 'Geçici ve Kalıcı Durum Yanıtı');
plot(t, original_signal, 'k:', 'DisplayName', 'Orijinal Sinyal');
hold on;
plot(t, filtered_clean_signal, 'b-', 'DisplayName', 'Filtrelenmiş Sinyal');
title(sprintf('Geçici ve Kalıcı Durum Yanıtı (N = %d)', N_transient_example));
xlabel('Zaman (s)');
ylabel('Genlik');
xlim([0, 2.5 * N_transient_example / Fs]);
ylim([-1.5, 1.5]);
grid on;
xline((N_transient_example-1)/Fs, '--r', sprintf('Geçici Durum Sonu (N-1=%d)', N_transient_example-1));
legend show;
hold off;