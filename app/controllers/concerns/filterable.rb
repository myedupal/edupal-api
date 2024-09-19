module Filterable
  extend ActiveSupport::Concern

  def status_scopable(records)
    if records.class == Class
      klass = records
    else
      klass = records.klass
    end

    if params[:status].present? and params[:status].is_a?(Array)
      status = klass.aasm.states.map(&:name).map(&:to_s) & params[:status]
      records.where(status: status)
    elsif params[:status].present? and klass.aasm.states.map(&:name).map(&:to_s).include?(params[:status])
      records.where(status: params[:status])
    else
      records
    end    
  end

  def date_scopable(records)
    if params[:from_date].present? and params[:to_date].present?
      from_time = Time.zone.parse(params[:from_date].to_s).beginning_of_day
      to_time   = Time.zone.parse(params[:to_date].to_s).end_of_day
      records.where(created_at: from_time..to_time)
    else
      records
    end
  end

  def custom_date_scopable(records, date_fields = [])
    if params[:from_date].present? && params[:to_date].present? && params[:date_by].present? && date_fields.include?(params[:date_by])
      from_time = Time.zone.parse(params[:from_date].to_s).beginning_of_day
      to_time = Time.zone.parse(params[:to_date].to_s).end_of_day
      records.where(params[:date_by] => from_time..to_time)
    else
      records
    end
  end

  def keyword_queryable(records)
    if params[:query].present?
      records.query(params[:query])
    else
      records
    end
  end

  def attribute_sortable(records)
    attributes = records.klass.attribute_names
    if params[:sort_by].present? and attributes.include?(params[:sort_by])
      if params[:sort_order].present? and params[:sort_order] == 'asc'
        records.order(params[:sort_by] => :asc)
      else
        records.order(params[:sort_by] => :desc)
      end
    else
      records.order(updated_at: :desc)
    end
  end

end
