# coding: utf-8
class FactorsController < ApplicationController
  before_filter :find_block, :only => [:new_factor, :save_weights, :edit_weights, :save_updated_weights]
  
  def show
  end
=begin
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
=end
end