#ifndef AUDIOUTILS_H
#define AUDIOUTILS_H

#include <QAudioBuffer>
#include <vector>
#include <algorithm>
#include <cmath>

// Function templates (Concept #12)
namespace AudioUtils {

// Template function to process audio samples
template<typename T>
void processSamples(QAudioBuffer& buffer, T processor) {
    if (buffer.format().sampleFormat() != QAudioFormat::Float) {
        return;
    }

    float* data = buffer.data<float>();
    int sampleCount = buffer.sampleCount();

    for (int i = 0; i < sampleCount; ++i) {
        data[i] = processor(data[i]);
    }
}

// Template function to analyze audio data
template<typename T, typename ResultType>
ResultType analyzeBuffer(const QAudioBuffer& buffer, T analyzer) {
    if (buffer.format().sampleFormat() != QAudioFormat::Float) {
        return ResultType();
    }

    const float* data = buffer.constData<float>();
    int sampleCount = buffer.sampleCount();

    return analyzer(data, sampleCount);
}

// Template function to convert between sample types
template<typename FromType, typename ToType>
std::vector<ToType> convertSamples(const std::vector<FromType>& input) {
    std::vector<ToType> output;
    output.reserve(input.size());

    for (const auto& sample : input) {
        output.push_back(static_cast<ToType>(sample));
    }

    return output;
}

// Template function for finding peaks
template<typename T>
std::vector<int> findPeaks(const std::vector<T>& samples, T threshold) {
    std::vector<int> peaks;

    for (size_t i = 1; i < samples.size() - 1; ++i) {
        if (samples[i] > threshold &&
            samples[i] > samples[i-1] &&
            samples[i] > samples[i+1]) {
            peaks.push_back(static_cast<int>(i));
        }
    }

    return peaks;
}

// Template function for normalizing audio
template<typename T>
void normalize(std::vector<T>& samples, T targetMax = 1.0) {
    if (samples.empty()) return;

    T maxVal = *std::max_element(samples.begin(), samples.end(),
                                 [](T a, T b) { return std::abs(a) < std::abs(b); });

    if (maxVal > 0) {
        T scale = targetMax / std::abs(maxVal);
        for (auto& sample : samples) {
            sample *= scale;
        }
    }
}

// Template function for applying fade
template<typename T>
void applyFade(std::vector<T>& samples, int fadeLength, bool fadeIn) {
    int length = std::min(fadeLength, static_cast<int>(samples.size()));

    for (int i = 0; i < length; ++i) {
        float factor = static_cast<float>(i) / length;
        if (!fadeIn) {
            factor = 1.0f - factor;
        }

        int index = fadeIn ? i : (samples.size() - length + i);
        samples[index] *= static_cast<T>(factor);
    }
}

// Template function for calculating RMS
template<typename T>
double calculateRMS(const std::vector<T>& samples) {
    if (samples.empty()) return 0.0;

    double sum = 0.0;
    for (const auto& sample : samples) {
        sum += sample * sample;
    }

    return std::sqrt(sum / samples.size());
}

} // namespace AudioUtils

#endif // AUDIOUTILS_H
