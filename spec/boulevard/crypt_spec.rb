describe Boulevard::Crypt, '.generate_key' do
  subject(:key) { described_class.generate_key }

  it 'generates a key without special characters' do
    expect(key).to match(/^[[:alnum:]]+$/)
  end
end

describe Boulevard::Crypt do
  subject(:crypt) { described_class.new(described_class.generate_key) }

  let(:original) { Random.new.bytes(rand(2**12) + 1) }

  let(:encrypted) { crypt.package(original) }

  it 'encrypts and decrypts to the same thing' do
    expect(crypt.unpackage(encrypted)).to eq original
  end

  it 'encrypts and decrypts to the same thing, even with new lines at the beginning and end' do
    expect(crypt.unpackage("\n\n#{encrypted}\n\n")).to eq original
  end

  it 'encodes as a base64 string' do
    expect { Base64.strict_decode64(encrypted) }.to_not raise_exception
  end

  def change_random_byte!(str)
    str[rand(str.size)] = Random.new.bytes(1)
  end

  it 'errors when the encrypted message is changed' do
    envelope = described_class.decode_envelope(encrypted)
    encrypted = envelope.fetch('encrypted')

    change_random_byte! encrypted

    reencrypted = described_class.encode_envelope(envelope)
    expect { crypt.unpackage(reencrypted) }.to raise_exception OpenSSL::Cipher::CipherError
  end
end
