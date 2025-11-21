#include "AudioEffect.h"
#include <cmath>
#include <algorithm>
#include <QDebug>

// ==================== EqualizerEffect ====================

EqualizerEffect::EqualizerEffect()
    : AudioEffect("Equalizer")
{
    // Initialize all bands to 0 dB (no change)
    for (int i = 0; i < BAND_COUNT; ++i) {
        m_bands[i] = 0.0f;
    }
}

EqualizerEffect::~EqualizerEffect()
{
    qDebug() << "EqualizerEffect destroyed";
}

void EqualizerEffect::apply(QAudioBuffer& buffer)
{
    if (!m_enabled || buffer.format().sampleFormat() != QAudioFormat::Float) {
        return;
    }

    float* data = buffer.data<float>();
    int sampleCount = buffer.sampleCount();

    // Apply each band filter
    for (int band = 0; band < BAND_COUNT; ++band) {
        if (std::abs(m_bands[band]) > 0.01f) {
            applyBandFilter(data, sampleCount, band, m_bands[band]);
        }
    }
}

AudioEffect* EqualizerEffect::clone() const
{
    EqualizerEffect* eq = new EqualizerEffect();
    for (int i = 0; i < BAND_COUNT; ++i) {
        eq->m_bands[i] = m_bands[i];
    }
    eq->setEnabled(isEnabled());
    return eq;
}

void EqualizerEffect::setBand(int band, float gain)
{
    if (band >= 0 && band < BAND_COUNT) {
        m_bands[band] = std::clamp(gain, -12.0f, 12.0f);
    }
}

float EqualizerEffect::getBand(int band) const
{
    if (band >= 0 && band < BAND_COUNT) {
        return m_bands[band];
    }
    return 0.0f;
}

void EqualizerEffect::setPreset(const QString& presetName)
{
    // Reset all bands
    for (int i = 0; i < BAND_COUNT; ++i) {
        m_bands[i] = 0.0f;
    }

    if (presetName == "Rock") {
        m_bands[0] = 5.0f;   // 32 Hz
        m_bands[1] = 3.0f;   // 64 Hz
        m_bands[2] = -2.0f;  // 125 Hz
        m_bands[3] = -3.0f;  // 250 Hz
        m_bands[4] = -1.0f;  // 500 Hz
        m_bands[5] = 2.0f;   // 1 kHz
        m_bands[6] = 4.0f;   // 2 kHz
        m_bands[7] = 5.0f;   // 4 kHz
        m_bands[8] = 5.0f;   // 8 kHz
        m_bands[9] = 5.0f;   // 16 kHz
    }
    else if (presetName == "Jazz") {
        m_bands[0] = 4.0f;
        m_bands[1] = 3.0f;
        m_bands[2] = 1.0f;
        m_bands[3] = 2.0f;
        m_bands[4] = -2.0f;
        m_bands[5] = -2.0f;
        m_bands[6] = 0.0f;
        m_bands[7] = 2.0f;
        m_bands[8] = 3.0f;
        m_bands[9] = 4.0f;
    }
    else if (presetName == "Classical") {
        m_bands[0] = 4.0f;
        m_bands[1] = 3.0f;
        m_bands[2] = 2.0f;
        m_bands[3] = 1.0f;
        m_bands[4] = -1.0f;
        m_bands[5] = -1.0f;
        m_bands[6] = 0.0f;
        m_bands[7] = 1.0f;
        m_bands[8] = 3.0f;
        m_bands[9] = 4.0f;
    }
}

void EqualizerEffect::applyBandFilter(float* samples, int sampleCount, int band, float gain)
{
    // Simplified gain application (in a real implementation, use proper filters)
    float linearGain = std::pow(10.0f, gain / 20.0f);

    for (int i = 0; i < sampleCount; ++i) {
        samples[i] *= linearGain;
        samples[i] = std::clamp(samples[i], -1.0f, 1.0f);
    }
}

// ==================== ReverbEffect ====================

ReverbEffect::ReverbEffect()
    : AudioEffect("Reverb")
    , m_roomSize(0.5f)
    , m_damping(0.5f)
    , m_wetDryMix(0.3f)
    , m_delayBufferPos(0)
{
    m_delayBuffer.resize(48000);  // 1 second at 48kHz
}

ReverbEffect::~ReverbEffect()
{
    qDebug() << "ReverbEffect destroyed";
}

void ReverbEffect::apply(QAudioBuffer& buffer)
{
    if (!m_enabled || buffer.format().sampleFormat() != QAudioFormat::Float) {
        return;
    }

    float* data = buffer.data<float>();
    int sampleCount = buffer.sampleCount();
    int delaySize = static_cast<int>(m_delayBuffer.size());

    for (int i = 0; i < sampleCount; ++i) {
        float dry = data[i];
        float wet = m_delayBuffer[m_delayBufferPos];

        // Mix wet and dry signals
        data[i] = dry * (1.0f - m_wetDryMix) + wet * m_wetDryMix;

        // Update delay buffer
        m_delayBuffer[m_delayBufferPos] = dry + wet * m_damping * m_roomSize;

        m_delayBufferPos = (m_delayBufferPos + 1) % delaySize;
    }
}

AudioEffect* ReverbEffect::clone() const
{
    ReverbEffect* reverb = new ReverbEffect();
    reverb->m_roomSize = m_roomSize;
    reverb->m_damping = m_damping;
    reverb->m_wetDryMix = m_wetDryMix;
    reverb->setEnabled(isEnabled());
    return reverb;
}

void ReverbEffect::setRoomSize(float size)
{
    m_roomSize = std::clamp(size, 0.0f, 1.0f);
}

void ReverbEffect::setDamping(float damping)
{
    m_damping = std::clamp(damping, 0.0f, 1.0f);
}

void ReverbEffect::setWetDryMix(float mix)
{
    m_wetDryMix = std::clamp(mix, 0.0f, 1.0f);
}

// ==================== BassBoostEffect ====================

BassBoostEffect::BassBoostEffect()
    : AudioEffect("Bass Boost")
    , m_boostLevel(1.5f)
{
}

BassBoostEffect::~BassBoostEffect()
{
    qDebug() << "BassBoostEffect destroyed";
}

void BassBoostEffect::apply(QAudioBuffer& buffer)
{
    if (!m_enabled || buffer.format().sampleFormat() != QAudioFormat::Float) {
        return;
    }

    float* data = buffer.data<float>();
    int sampleCount = buffer.sampleCount();

    // Simple bass boost (in reality, use a low-pass filter)
    for (int i = 0; i < sampleCount; ++i) {
        data[i] *= m_boostLevel;
        data[i] = std::clamp(data[i], -1.0f, 1.0f);
    }
}

AudioEffect* BassBoostEffect::clone() const
{
    BassBoostEffect* bass = new BassBoostEffect();
    bass->m_boostLevel = m_boostLevel;
    bass->setEnabled(isEnabled());
    return bass;
}

void BassBoostEffect::setBoostLevel(float level)
{
    m_boostLevel = std::clamp(level, 0.5f, 2.0f);
}

// ==================== EffectChain ====================

void EffectChain::addEffect(std::unique_ptr<AudioEffect> effect)
{
    m_effects.push_back(std::move(effect));
}

void EffectChain::removeEffect(int index)
{
    if (index >= 0 && index < static_cast<int>(m_effects.size())) {
        m_effects.erase(m_effects.begin() + index);
    }
}

void EffectChain::clearEffects()
{
    m_effects.clear();
}

void EffectChain::processBuffer(QAudioBuffer& buffer)
{
    for (auto& effect : m_effects) {
        if (effect && effect->isEnabled()) {
            effect->apply(buffer);
        }
    }
}

AudioEffect* EffectChain::getEffect(int index)
{
    if (index >= 0 && index < static_cast<int>(m_effects.size())) {
        return m_effects[index].get();
    }
    return nullptr;
}
