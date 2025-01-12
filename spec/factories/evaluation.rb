# frozen_string_literal: true

FactoryBot.define do
  factory :evaluation do
    nom { 'Roger' }
    campagne
    beneficiaire
    debutee_le { 1.hour.ago }

    trait :terminee do
      terminee_le { Time.current }
    end

    trait :avec_mise_en_action do
      transient do
        effectuee { true }
        repondue_le { Time.zone.local(2023, 1, 1, 12, 0, 0) }
        dispositif_de_remediation { nil }
      end

      after(:create) do |evaluation, evaluator|
        create(:mise_en_action, evaluation: evaluation)
        evaluation.mise_en_action.update(
          effectuee: evaluator.effectuee,
          repondue_le: evaluator.repondue_le,
          dispositif_de_remediation: evaluator.dispositif_de_remediation
        )
      end
    end
  end
end
