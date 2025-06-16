function bnoise = bluenoise(N)
% BLUENOISE f genlik spektrumu kullanarak mavi gürültü üretir.
%   N - Üretilecek gürültü örneği sayısı

    white = randn(1, N);
    S = fft(white);
    f = 1:floor(N/2)+1;

    % Genlikleri sqrt(f) ile ölçekle
    S(1:length(f)) = S(1:length(f)) .* sqrt(f);

    % Spektrumun ikinci yarısını simetrik yap
    S(N-length(f)+2:end) = conj(fliplr(S(2:length(f))));

    % Ters Fourier dönüşümü ile zaman domenine dön
    bnoise = real(ifft(S));
end