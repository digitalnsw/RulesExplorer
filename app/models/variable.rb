# frozen_string_literal: true

class Variable < ApplicationRecord
  validates :name, presence: true
  validates :entity, presence: true
  translates :description
  extend FriendlyId
  friendly_id :name

  belongs_to :value_type
  belongs_to :entity

  has_many :scenario_variables, dependent: :destroy
  has_many :scenarios, through: :scenario_variables

  def input_scenarios
    scenarios.merge(ScenarioVariable.input)
  end

  def output_scenarios
    scenarios.merge(ScenarioVariable.output)
  end

  has_and_belongs_to_many(:variables,
                          class_name: 'Variable',
                          join_table: 'links',
                          foreign_key: 'link_to',
                          association_foreign_key: 'link_from')

  has_and_belongs_to_many(:reversed_variables,
                          class_name: 'Variable',
                          join_table: 'links',
                          foreign_key: 'link_from',
                          association_foreign_key: 'link_to')

  def has_formula?
    spec['formulas'].present?
  end

  def github_url
    "#{ENV['GITHUB_URL']}#{spec['source'].gsub('//', '/tree/master/').gsub('blob', '').gsub(
      '/app/', '/'
    )}"
  rescue StandardError
    nil
  end

  def to_s
    name
  end

  def inbound_links
    reversed_variables
  end

  def outbound_links
    variables
  end

  def orphaned?
    inbound_links.empty? && outbound_links.empty?
  end
end
