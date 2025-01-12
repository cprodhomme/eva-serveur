# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    libelle { 'Question' }
    nom_technique { 'question' }
    intitule { 'Ma Question' }
  end

  factory :question_qcm do
    libelle { 'Question QCM' }
    nom_technique { 'question-qcm' }
    intitule { 'Quel est le bon choix ?' }
  end

  factory :question_redaction_note do
    libelle { 'Question Redaction Note' }
    nom_technique { 'question-redaction-note' }
    intitule { 'Ecrivez une note' }
  end
end
