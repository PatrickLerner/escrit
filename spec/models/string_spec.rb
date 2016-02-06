require 'rails_helper'

describe String do
  using StringRefinements

  it 'has a refinement' do
    String.methods.include? :utf8downcase
  end

  it 'works on international characters correctly' do
    expect("ПРАZAD".utf8downcase).to eq("праzad")
  end
end
