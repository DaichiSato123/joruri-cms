# encoding: utf-8
class Faq::Node::Doc < Cms::Node
  def setting_label(name)
    value = setting_value(name)
    case name
    when :show_concept_id
      return show_concept ? show_concept.name : nil
    when :show_layout_id
      return show_layout ? show_layout.title : nil
    end
    value
  end

  def show_concept
    @show_concept = Cms::Concept.find_by(id: setting_value(:show_concept_id))
  end

  def show_layout
    @show_layout = Cms::Layout.find_by(id: setting_value(:show_layout_id))
  end
end
