require 'rails_helper'

describe Category, type: :model do
  describe 'generation' do
    let!(:text) { create(:text) }
    let(:categories) { Category.where(value: text.category, user: text.user) }

    it 'is generated when a text is created' do
      expect(categories.count).to eq(1)
    end

    it 'references all texts' do
      2.times do
        create(:text,
          user: text.user,
          language: text.language,
          category: text.category
        )
      end
      expect(categories.count).to eq(1)
      expect(categories.first.texts.count).to eq(3)
    end
  end

  describe 'change' do
    let!(:text) { create(:text) }
    let!(:original_category) { text.__category }

    before(:each) do
      text.update_attributes(category: 'this is a new category')
    end

    it 'adds a category if I change it' do
      expect(text.__category.id).to_not eq(original_category.id)
    end

    it 'destroys a useless category object' do
      expect(Category.find_by(id: original_category.id)).to be_nil
    end

    describe 'merge' do
      let!(:sec_text) do
        create(:text, user: text.user, language: text.language, category: 'new')
      end

      it 'merges into the same category' do
        sec_text.update_attributes(category: text.category)
        expect(text.category).to eq(sec_text.category)
        expect(text.__category).to eq(sec_text.__category)
      end

      it 'destroys the old category when merging' do
        expect{
          sec_text.update_attributes(category: text.category)
        }.to change { Category.all.count }.by(-1)
      end
    end
  end

  describe 'public texts' do
    let!(:text) { create(:text, public: true) }

    it 'has a public category' do
      expect(text.__category.user_id).to eq(nil)
    end
  end

  describe 'destruction' do
    let!(:text_1) { create(:text) }
    let!(:text_1_attr) do
      {
        user: text_1.user, language: text_1.language, category: text_1.category
      }
    end
    let!(:text_2) { create(:text, text_1_attr) }
    let!(:text_3) { create(:text) }
    let!(:text_3_attr) do
      {
        user: text_3.user, language: text_3.language, category: text_3.category
      }
    end
    let!(:text_4) { create(:text) }
    let!(:cat_count) { 3 }

    it 'destroys things correctly' do
      expect(Category.count).to eq(cat_count)
      new_text = create(:text)
      expect(Category.count).to eq(cat_count + 1)
      new_text.destroy
      expect(Category.count).to eq(cat_count)
      new_text = create(:text, text_3_attr)
      expect(Category.count).to eq(cat_count)
      new_text.destroy
      expect(Category.count).to eq(cat_count)
    end
  end
end
