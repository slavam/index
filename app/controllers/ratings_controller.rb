# coding: utf-8
class RatingsController < ApplicationController
  before_filter :find_direction, :only => [:show_rating, :show_indexes, :calc_rating, :show_index_changes, 
    :show_value_changes, :show_factor_chart, :show_index_chart]
  before_filter :find_period, :only => [:show_rating, :show_indexes, :calc_rating, :show_index_changes, 
    :show_value_changes, :show_factor_chart, :show_index_chart]
 
  def get_rating_params
  end

  def get_calc_params
  end

  def show_rating
    @values = find_values @period.id, @direction.id
    @prev_period = get_prev_period(@period)
    if @prev_period
      @prev_values = find_values @prev_period.id, @direction.id
    end  
  end

  def show_indexes
    @values = find_values @period.id, @direction.id
    @prev_period = get_prev_period(@period)
    if @prev_period
      @prev_values = find_values @prev_period.id, @direction.id
    end  
  end

  def show_factor_chart
    @values = Rating.where("period_id = ? and scope_id = ? and factor_id = ?", 
      @period.id, @direction.id, params[:factor_id]).order(:division_id)
  end
  
  def show_index_chart
    @values = Rating.where("period_id = ? and scope_id = ? and factor_id = ?", 
      @period.id, @direction.id, params[:factor_id]).order(:division_id)
  end

  def show_index_changes
    @curr_values = Rating.where("period_id = ? and scope_id = ? and division_id = ?", 
      @period.id, @direction.id, params[:division_id]).order(:factor_id)
    @prev_values = Rating.where("period_id = ? and scope_id = ? and division_id = ?", 
      @period.id-1, @direction.id, params[:division_id]).order(:factor_id)
  end 

  def show_value_changes
    @curr_values = Rating.where("period_id = ? and scope_id = ? and division_id = ?", 
      @period.id, @direction.id, params[:division_id]).order(:factor_id)
    @prev_values = Rating.where("period_id = ? and scope_id = ? and division_id = ?", 
      @period.id-1, @direction.id, params[:division_id]).order(:factor_id)
  end
  
  def calc_rating
    @factors = Factor.find_by_sql('
    select * from factors where subgroup_id in
      (select id from subgroups where group_id in 
      (select id from groups where scope_id ='+ params[:rating_params][:direction_id].to_s+'))') 
#    d = Direction.find params[:rating_params][:direction_id]
    branch_id = params[:rating_params][:direction_id].to_i+1
    @divisions = Division.find_by_sql('
      select d.id id, d.code code from FIN.division d
        join FIN.division_branch db on db.id=d.division_branch_id and db.id='+branch_id.to_s+
        ' where d.open_date IS NOT NULL
    ')
    start_date = @period.start_date
    end_date = @period.end_date
    a_fr = []
    a_we = []
    a_be = []
    @divisions.collect { |d|
          a_fr << get_fin_res( '2011-1-1'.to_date, end_date, d.code)
          workers_count = Worker.select(:code_division).where('code_division like ?', d.code+'%').size
          a_we << get_work_efficiency( start_date, end_date, d.code, workers_count)
          a_be << get_business_efficiencies( '2011-1-1'.to_date, end_date, d.code)
    }
    
      @factors.collect { |f|
        if f.factor_description.id == 1
          v_max = a_fr.max
          v_min = a_fr.min
# !!!!! change 0.35 to real weight          
          i = 0
          a_fr.each {|e|
            rating = Rating.new
            rating.period_id = @period.id
            rating.division_id = @divisions[i].id
            rating.group_id = f.subblock.group_id
            rating.subgroup_id = f.subblock.id
            rating.factor_id = f.id
            rating.value = e
            rating.index_value = 0.35*(v_max-e)/(v_max-v_min)
            rating.calc_date = Time.now
            rating.scope_id = params[:rating_params][:direction_id]
            rating.save
            i += 1
          }
        end
        if f.factor_description.id == 2
          v_max = a_we.max
          v_min = a_we.min
# !!!!! change 0.35 to real weight          
          i = 0
          a_we.each {|e| 
            rating = Rating.new
            rating.period_id = @period.id
            rating.division_id = @divisions[i].id
            rating.group_id = f.subblock.group_id
            rating.subgroup_id = f.subblock.id
            rating.factor_id = f.id
            rating.value = e
            rating.index_value = 0.35*(v_max-e)/(v_max-v_min)
            rating.calc_date = Time.now
            rating.scope_id = params[:rating_params][:direction_id]
            rating.save
            i += 1
          }
        end
        if f.factor_description.id == 3
          v_max = a_be.max
          v_min = a_be.min
# !!!!! change 0.30 to real weight          
          i = 0
          a_be.each {|e| 
            rating = Rating.new
            rating.period_id = @period.id
            rating.division_id = @divisions[i].id
            rating.group_id = f.subblock.group_id
            rating.subgroup_id = f.subblock.id
            rating.factor_id = f.id
            rating.value = e
            rating.index_value = 0.30*(v_max-e)/(v_max-v_min)
            rating.calc_date = Time.now
            rating.scope_id = params[:rating_params][:direction_id]
            rating.save
            i += 1
          }
        end
      
      }
   
    redirect_to :action => 'show_rating', :direction_id => @direction,  :period_id => @period
  end

  private
  
  def get_prev_period curr_period
    delta_month = curr_period.end_date.month - curr_period.start_date.month + 1
    start_date = curr_period.start_date.months_ago(delta_month).beginning_of_month
    end_date = curr_period.end_date.months_ago(delta_month).end_of_month
    return Period.where('start_date=? and end_date=?', start_date, end_date).first 
  end
  
  def find_direction
    if params[:direction_id]
      @direction = Direction.find params[:direction_id]
    else
      @direction = Direction.find params[:rating_params][:direction_id]
    end  
  end
  
  def find_period
    if params[:period_id]
      @period = Period.find params[:period_id]
    else
      @period = Period.find params[:rating_params][:period_id]
    end  
  end
  
  def find_values period_id, direction_id
    return Rating.where("period_id = ? and scope_id = ? ", 
      period_id, direction_id).order(:division_id)
  end
  
  def get_business_efficiencies start_date, end_date, division_code
    s_m = start_date.month
    e_m = end_date.month
    s_d = s_m.to_s+'_'+start_date.day.to_s
    e_d = e_m.to_s+'_'+end_date.day.to_s
    query = "select d.namepp, d.name,
        (t.MONTH_2011_"+e_d+" - t.MONTH_2011_"+s_d+") as fact
      from rpk880508.REZULT_"+division_code+" t, rpk880508.directory d
      where d.id = t.id_directory
        and d.output_biz is null
        and (d.namepp like '%00.00.06.00.00.00'
        or d.namepp like '%00.00.07.00.00.00'
        or d.namepp like '%05.01.00.00.00.00'
        or d.namepp like '%00.00.01.00.00.00')
      order by d.namepp"    
    be_data = Division.find_by_sql(query)
    if (be_data[0].fact+be_data[3].fact) == 0
      return 0
    else
      return (be_data[1].fact+be_data[2].fact)/(be_data[0].fact+be_data[3].fact)
    end
  end
  
  def get_work_efficiency start_date, end_date, division_code, workers_count
    s_m = start_date.month
    e_m = end_date.month
    s_d = s_m.to_s+'_'+start_date.day.to_s
    e_d = e_m.to_s+'_'+end_date.day.to_s
    m_a = []
    for i in (s_m..e_m)
      m_a << i 
    end
    s_p = 't.plan_'+m_a.join('+t.plan_')
    query = 'select decode(sign('+s_p+'), 0, 0,
      round(((t.MONTH_2011_'+e_d+' - t.MONTH_2011_'+s_d+' - ('+s_p+')) /
      abs('+s_p+') + 1) * 100, 2)) as work_efficiency
      from rpk880508.REZULT_'+division_code+" t, rpk880508.directory d
    where d.id = t.id_directory
      and output_biz is null
      and not (output_bank in (9))
      and d.namepp like '%00.00.11.00.00.00'"
    
    return Division.find_by_sql(query).first.work_efficiency/workers_count
  end
  
  def get_fin_res start_date, end_date, division_code
    s_m = start_date.month
    e_m = end_date.month
    s_d = s_m.to_s+'_'+start_date.day.to_s
    e_d = e_m.to_s+'_'+end_date.day.to_s
    m_a = []
    for i in (s_m..e_m)
      m_a << i 
    end
    s_p = 't.plan_'+m_a.join('+t.plan_')
    query = 'select decode(sign('+s_p+'), 0, 0,
      round(((t.MONTH_2011_'+e_d+' - t.MONTH_2011_'+s_d+' - ('+s_p+')) /
      abs('+s_p+') + 1) * 100, 2)) as fin_res
      from rpk880508.REZULT_'+division_code+" t, rpk880508.directory d
    where d.id = t.id_directory
      and output_biz is null
      and not (output_bank in (9))
      and d.namepp like '%00.00.05.00.00.00'"
    
    return Division.find_by_sql(query).first.fin_res
  end
  
=begin
# a.force_encoding("CP1251").encode("UTF-8")    

select * from indexes where division_id in 
(select max(division_id) from indexes)

 select d.namepp,
 d.name,
 t.plan_1 as PLAN,
 (t.MONTH_2011_1_31 - t.MONTH_2011_1_1) as FACT,
 (t.MONTH_2011_1_31 - t.MONTH_2011_1_1 - (t.plan_1)) as OTKLON,
 decode(sign(t.plan_1), 0, 0,
 round(((t.MONTH_2011_1_31 - t.MONTH_2011_1_1 - (t.plan_1)) /
 abs(t.plan_1) + 1) * 100, 2)) PRESSENT
 from rpk880508.REZULT_013 t, rpk880508.directory d
 where d.id = t.id_directory
 and output_biz is null
 and not (output_bank in (9))
  and d.namepp = 'п00.00.11.00.00.00'  ---Финансовый результат без распределения расходов поддержек (1)(3-category)
 order by d.namepp


3
select d.namepp,
       d.name,
       (t.MONTH_2011_1_31 - t.MONTH_2011_1_1) as FACT
  from rpk880508.REZULT_013 t,
       rpk880508.directory d
 where d.id = t.id_directory
   and d.output_biz is null
   and (d.namepp in ('п00.00.06.00.00.00','п00.00.07.00.00.00')
    or d.namepp in ('п05.01.00.00.00.00','п00.00.01.00.00.00'))
 order by d.namepp 

5
select d.namepp,
 d.name,
 (t.plan_1) as PLAN,
 (t.MONTH_2011_1_31 - t.MONTH_2011_1_1) as FACT,
 (t.MONTH_2011_1_31 - t.MONTH_2011_1_1 - (t.plan_1)) as OTKLON,
 decode(sign(t.plan_1), 0, 0,
 round(((t.MONTH_2011_1_31 - t.MONTH_2011_1_1 - (t.plan_1)) /
 abs((t.plan_1)) + 1) * 100, 2)) PRESSENT
 from rpk880508.REZULT_013 t, rpk880508.directory d
 where d.id = t.id_directory
 and output_biz is null
 and not (output_bank in (9))
 and d.namepp = 'п01.03.03.00.01.00'  ---Доходы от валютообменных операций (5)
 order by d.namepp

select * from FIN.division d
join FIN.division_branch db on db.id=d.division_branch_id and db.id=4
where d.open_date IS NOT NULL
  
=end
end