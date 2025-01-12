# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :model do
  ActiveJob::Base.queue_adapter = :test

  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_uniqueness_of(:nom).scoped_to(:code_postal).case_insensitive }

  describe 'REGEX_UUID' do
    it { expect('uuid invalide').not_to match(Structure::REGEX_UUID) }
    it { expect(SecureRandom.uuid).to match(Structure::REGEX_UUID) }
  end

  describe 'géolocalisation à la validation' do
    describe "pour n'importe quel code postal" do
      let(:structure) { Structure.new code_postal: '75012' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '75012', [
            {
              'coordinates' => [40.7143528, -74.0059731],
              'state' => 'Île-de-France'
            }
          ]
        )
        structure.valid?
      end

      it do
        expect(structure.latitude).to be(40.7143528)
        expect(structure.longitude).to be(-74.0059731)
        expect(structure.region).to eql('Île-de-France')
      end

      it { expect(Structure.geocoder_options[:params]).to include(countrycodes: 'fr') }
    end

    describe 'si ma structure a un code postal commençant par 988' do
      let(:structure) { Structure.new code_postal: '98850' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '98850', [
            {
              'state' => '',
              'coordinates' => [47.3129, 120.0596]
            }
          ]
        )
        structure.valid?
      end

      it 'lui attribue la région Nouvelle-Calédonie' do
        expect(structure.region).to eql('Nouvelle-Calédonie')
      end
    end

    describe 'si ma structure a un code postal commençant par 20' do
      let(:structure) { Structure.new code_postal: '20090' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '20090', [
            {
              'state' => '',
              'coordinates' => [41.9333, 8.7507]
            }
          ]
        )
        structure.valid?
      end

      it 'lui attribue la région Corse' do
        expect(structure.region).to eql('Corse')
      end
    end

    describe 'si ma structure a un code postal commençant par 21' do
      let(:structure) { Structure.new code_postal: '20114' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '20114', [
            {
              'state' => '',
              'coordinates' => [41.5188, 9.1264]
            }
          ]
        )
        structure.valid?
      end

      it 'lui attribue la région Corse' do
        expect(structure.region).to eql('Corse')
      end
    end

    context 'quand ma structure a déjà une région' do
      let(:structure) { Structure.new code_postal: '20114', region: 'Corse' }

      before do
        structure.code_postal = '61000'
        Geocoder::Lookup::Test.add_stub(
          '61000', [
            {
              'state' => 'Normandie',
              'coordinates' => [48.4310232, 0.0922579]
            }
          ]
        )
        structure.valid?
      end

      it 'lui attribue la nouvelle région' do
        expect(structure.region).to eql('Normandie')
      end
    end
  end

  describe 'à la création' do
    it 'programme un mail de relance' do
      expect { create :structure, :avec_admin }
        .to have_enqueued_job(RelanceStructureSansCampagneJob).exactly(1)
    end
  end
end
