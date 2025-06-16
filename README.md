# FIR Filtreler Kullanarak Gürültülü Sinyallerin SNR İyileştirilmesi ve Filtre Uzunluğu Analizi

![MATLAB](https://img.shields.io/badge/MATLAB-R2021b%2B-orange.svg)
![Lisans](https://img.shields.io/badge/License-MIT-blue.svg)

Bu depo, **ELE-306 Sayısal İşaret İşleme Dersi** kapsamında gerçekleştirilen final projesini içermektedir. Proje, farklı istatistiksel özelliklere sahip gürültülerle (beyaz, pembe, mavi) bozulmuş bir sinüzoidal sinyalin, Sonlu Dürtü Yanıtlı (FIR) filtreler kullanılarak kalitesinin artırılmasını ve bu süreçte filtre parametrelerinin etkisini analiz etmeyi amaçlamaktadır.

---

## 📖 Projenin Amacı

Projenin temel hedefleri şunlardır:
- Farklı başlangıç Sinyal-Gürültü Oranlarına (-6 dB, 0 dB, 6 dB) sahip gürültülü sinyaller oluşturmak.
- Alçak Geçiren (LPF), Yüksek Geçiren (HPF) ve Bant Geçiren (BPF) FIR filtreler tasarlamak.
- **30 dB** çıkış SNR hedefine ulaşmak için gereken **minimum filtre uzunluğunu ($N_{min}$)** sistematik olarak bulmak.
- Filtre uzunluğunun (N), filtrenin frekans yanıtı, gürültü bastırma performansı ve işlem karmaşıklığı üzerindeki etkilerini analiz etmek.
- Farklı gürültü ve filtre türleri için performans-maliyet ödünleşmesini değerlendirmek.

## 🔑 Temel Konseptler

- **Sinyal-Gürültü Oranı (SNR):** Bir sinyalin gücünün arka plandaki gürültünün gücüne oranıdır ve sinyal kalitesinin temel bir ölçütüdür.
- **Gürültü Modelleri:**
  - **Beyaz Gürültü:** Gücü tüm frekanslara eşit yayılmıştır.
  - **Pembe Gürültü:** Gücü düşük frekanslarda yoğundur ($1/f$).
  - **Mavi Gürültü:** Gücü yüksek frekanslarda yoğundur ($f$).
- **FIR Filtreler:** Sadece giriş örneklerini kullanan, her zaman kararlı ve kolayca doğrusal fazlı tasarlanabilen sayısal filtrelerdir. Bu projede `Hamming` penceresi kullanılarak tasarlanmışlardır.

---

## 📂 Depo İçeriği

Bu depoda aşağıdaki dosyalar bulunmaktadır:

├── proje_ana_kod.m             # Projenin tüm adımlarını yürüten ana MATLAB betiği
├── design_fir_filter.m         # FIR filtreleri tasarlayan yardımcı fonksiyon
├── pinknoise.m                 # Pembe gürültü üreten yardımcı fonksiyon
├── bluenoise.m                 # Mavi gürültü üreten yardımcı fonksiyon
└── README.md                   # Bu dosya

---

## 🚀 Kurulum ve Çalıştırma

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

1.  **Depoyu Klonlayın:**
    ```bash
    git clone [https://github.com/KULLANICI_ADINIZ/FIR-Filter-SNR-Analysis.git](https://github.com/KULLANICI_ADINIZ/FIR-Filter-SNR-Analysis.git)
    ```
2.  **MATLAB'i Açın:** Klonladığınız klasörü MATLAB'de açın.
3.  **Betiği Çalıştırın:** Tüm `.m` dosyalarının aynı klasörde olduğundan emin olun ve komut penceresine aşağıdaki komutu yazarak ana betiği çalıştırın:
    ```matlab
    proje_ana_kod
    ```
4.  **Sonuçları Gözlemleyin:** Betik çalışmaya başladığında, komut penceresinde her bir senaryo için yapılan analizleri ve bulunan $N_{min}$ değerlerini göreceksiniz. Çalışma tamamlandığında, sonuçların özet tablosu komut penceresine yazdırılacak ve analiz için gerekli karşılaştırmalı grafikler otomatik olarak oluşturulacaktır.

---

## 📊 Elde Edilen Temel Sonuçlar ve Çıkarımlar

Bu projenin sonunda elde edilen en önemli mühendislik çıkarımları şunlardır:

* **BPF'nin Üstünlüğü:** Bant Geçiren Filtre (BPF), sinyalin frekansını hassas bir şekilde hedefleyebildiği için diğer tüm filtre türlerinden çok daha üstün bir performans göstermiştir.
* **Bağlamın Önemi:** Bir filtrenin etkinliği, sadece kendi türüne değil, **sinyal ve gürültünün frekans spektrumundaki göreceli konumlarına** kritik derecede bağlıdır. Projemizdeki sinyal (2917 Hz) yüksek bir frekansta olduğu için, LPF filtresi mavi gürültünün en güçlü olduğu bölgeyi de içeri almak zorunda kalmış ve tamamen başarısız olmuştur. Bu, "doğru aracın yanlış problemde" nasıl işe yaramadığının mükemmel bir örneğidir.
* **Fizibilite ve Limitler:** 30 dB gibi yüksek bir hedefe ulaşmak her zaman mümkün değildir. Bu hedefe sadece, BPF filtresinin pembe ve mavi gürültü gibi belirli gürültü türleriyle ve görece iyi başlangıç koşullarında birleştiği birkaç senaryoda ulaşılabilmiştir.
* **Performans-Maliyet Ödünleşmesi:** Daha zorlu bir senaryoyu çözmek, çok daha yüksek bir işlem maliyeti gerektirir. Örneğin, pembe gürültüyü temizlemek için $N=109$ yeterliyken, mavi gürültü için $N=905$ gerekmesi, performans artışının maliyetinin doğrusal olmadığını göstermektedir.

## 🖼️ Görsel Sonuçlar Örnekleri

*(Buraya `proje_ana_kod.m` betiğinin ürettiği en önemli birkaç grafiğin ekran görüntüsünü ekleyebilirsiniz.)*

**Örnek 1: Filtre Türü Karşılaştırması** - Bu grafik, BPF'nin LPF ve HPF'ye göre performans üstünlüğünü açıkça gösterir.
`![Filtre Türü Karşılaştırması](path/to/your/image1.png)`

**Örnek 2: "İyi" vs "Kötü" Filtre Frekans Yanıtı** - Bu grafik, başarılı bir BPF ile başarısız bir LPF'nin frekans yanıtlarını karşılaştırarak neden birinin çalışıp diğerinin çalışmadığını görsel olarak açıklar.
`![Frekans Yanıtı Karşılaştırması](path/to/your/image2.png)`

---

## 🎓 Ders Bilgileri

Bu proje, **Süleyman Demirel Üniversitesi Elektrik-Elektronik Mühendisliği Bölümü**'nde, **Dr. Öğr. Üyesi Turgay KOÇ** tarafından yürütülen **ELE-306 Sayısal İşaret İşleme** dersi kapsamında hazırlanmıştır.