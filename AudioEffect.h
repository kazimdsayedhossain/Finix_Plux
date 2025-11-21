#ifndef AUDIOEFFECT_H
#define AUDIOEFFECT_H

#include <QString>
#include <QAudioBuffer>
#include <memory>

// Abstract base class (Concept #11)
class AudioEffect {
public:
    AudioEffect(const QString& name) : m_name(name), m_enabled(true) {}
    virtual ~AudioEffect() = default;  // Virtual destructor (Concept #10)

    // Pure virtual functions (Concept #11)
    virtual void apply(QAudioBuffer& buffer) = 0;
    virtual AudioEffect* clone() const = 0;

    // Virtual functions (Concept #10)
    virtual QString effectName() const { return m_name; }
    virtual void reset() { m_enabled = true; }

    bool isEnabled() const { return m_enabled; }
    void setEnabled(bool enabled) { m_enabled = enabled; }

protected:
    QString m_name;
    bool m_enabled;
};

// Equalizer Effect
class EqualizerEffect : public AudioEffect {
public:
    EqualizerEffect();
    ~EqualizerEffect() override;

    void apply(QAudioBuffer& buffer) override;
    AudioEffect* clone() const override;

    void setBand(int band, float gain);
    float getBand(int band) const;
    void setPreset(const QString& presetName);

    static constexpr int BAND_COUNT = 10;

private:
    float m_bands[BAND_COUNT];

    void applyBandFilter(float* samples, int sampleCount, int band, float gain);
};

// Reverb Effect
class ReverbEffect : public AudioEffect {
public:
    ReverbEffect();
    ~ReverbEffect() override;

    void apply(QAudioBuffer& buffer) override;
    AudioEffect* clone() const override;

    void setRoomSize(float size);  // 0.0 to 1.0
    void setDamping(float damping);  // 0.0 to 1.0
    void setWetDryMix(float mix);  // 0.0 to 1.0

private:
    float m_roomSize;
    float m_damping;
    float m_wetDryMix;
    std::vector<float> m_delayBuffer;
    int m_delayBufferPos;
};

// Bass Boost Effect
class BassBoostEffect : public AudioEffect {
public:
    BassBoostEffect();
    ~BassBoostEffect() override;

    void apply(QAudioBuffer& buffer) override;
    AudioEffect* clone() const override;

    void setBoostLevel(float level);  // 0.0 to 2.0

private:
    float m_boostLevel;
};

// Effect Manager using polymorphism
class EffectChain {
public:
    void addEffect(std::unique_ptr<AudioEffect> effect);
    void removeEffect(int index);
    void clearEffects();

    void processBuffer(QAudioBuffer& buffer);

    int effectCount() const { return static_cast<int>(m_effects.size()); }
    AudioEffect* getEffect(int index);

private:
    std::vector<std::unique_ptr<AudioEffect>> m_effects;  // STL Container
};

#endif // AUDIOEFFECT_H
