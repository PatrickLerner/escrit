module PanelsHelper
  def panel(headline: nil, &block)
    content_tag :div, class: 'panel' do
      if headline.present?
        concat content_tag(:div, headline.html_safe, class: 'panel-header')
      end
      concat content_tag(:div, class: 'panel-body', &block)
    end
  end
end
