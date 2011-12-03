
#cfr_directors = ["Carla A. Hills", "Robert E. Rubin", "Richard E. Salomon",  "Richard N. Haass", "John P. Abizaid", "Peter Ackerman", "Fouad Ajami", "Madeleine K. Albright", "Alan S. Blinder", "Mary Boies", "David G. Bradley",  "Tom Brokaw", "Sylvia Mathews Burwell", "Kenneth M. Duberstein", "Martin S. Feldstein", "Stephen Friedman","Ann M. Fudge", "Pamela Gann", "Thomas H. Glocer",  "J. Tomilson Hill","Donna J. Hrinak", "Alberto Ibargüen", "Shirley Ann Jackson", "Henry R. Kravis", "Jami Miscik", "Joseph S. Nye",  "James W. Owens",  "Eduardo J. Padrón", "Colin L. Powell", "Penny Pritzker", "David M. Rubenstein",   "George Rupp", "Frederick W. Smith",  "Christine Todd Whitman", "Fareed Zakaria",  "Leslie H. Gelb", "Maurice R. Greenberg",  "Peter G. Peterson","David Rockefeller"]

    

cfr_directors = [
    {:middle=>"A", :first=>"Carla", :last=>"Hills", :cik_id=> "0001194913"},
    {:middle=>"E", :first=>"Robert", :last=>"Rubin", :cik_id=> "0001225178"},
    {:middle=>"E", :first=>"Richard", :last=>"Salomon", :cik_id => "0001217109"},
    {:middle=>"N", :first=>"Richard", :last=>"Haass", :cik_id => "0001123553"},
    {:middle=>"P", :first=>"John", :last=>"Abizaid", :cik_id => "0001425152"},
    {:first=>"Peter", :last=>"Ackerman", :cik_id => "0001111564"},
    {:first=>"Fouad", :last=>"Ajami"},
    {:middle=>"K", :first=>"Madeleine", :last=>"Albright"},
    {:middle=>"S", :first=>"Alan", :last=>"Blinder"},
    {:first=>"Mary", :last=>"Boies", :cik_id => "0001291933"},
    {:middle=>"G", :first=>"David", :last=>"Bradley", :cik_id=> "0001106734"},
    {:first=>"Tom", :last=>"Brokaw"},
    {:first=>"Sylvia", :last=>"Burwell"},
    {:middle=>"M", :first=>"Kenneth", :last=>"Duberstein", :cik_id=> "0001179625"},
    {:middle=>"S", :first=>"Martin", :last=>"Feldstein", :cik_id=> "0001236596"},
    {:first=>"Stephen", :last=>"Friedman", :cik_id=> "0001029607"},
    {:middle=>"M", :first=>"Ann", :last=>"Fudge", :cik_id=> "0001198098"},
    {:first=>"Pamela", :last=>"Gann"},
    {:middle=>"H", :first=>"Thomas", :last=>"Glocer", :cik_id=> "0001140799"},
    {:middle=>"J", :first=>"J.", :last=>"Hill"},
    {:middle=>"J", :first=>"Donna", :last=>"Hrinak", :cik_id=> "0001296811"},
    {:first=>"Alberto", :last=>"Ibarguen", :cik_id=> "0001339732"},
    {:first=>"Shirley", :last=>"Jackson", :cik_id=> "0001168019"},
    {:middle=>"R", :first=>"Henry", :last=>"Kravis", :cik_id=> "0001081714"},
    {:first=>"Jami", :last=>"Miscik"},
    {:middle=>"S", :first=>"Joseph", :last=>"Nye", :cik_id=> "0001299821"},
    {:middle=>"W", :first=>"James", :last=>"Owens", :cik_id=> "0001443909"},
    {:middle=>"J", :first=>"Eduardo", :last=>"Padron"},
    {:middle=>"L", :first=>"Colin", :last=>"Powell"},
    {:first=>"Penny", :last=>"Pritzker", :cik_id=> "0001087398"},
    {:middle=>"M", :first=>"David", :last=>"Rubenstein"},
    {:first=>"George", :last=>"Rupp"},
    {:middle=>"W", :first=>"Frederick", :last=>"Smith", :cik_id=> "0001033677"},
    {:first=>"Christine", :last=>"Whitman", :cik_id=> "0001271384"},
    {:first=>"Fareed", :last=>"Zakaria"},
    {:middle=>"H", :first=>"Leslie", :last=>"Gelb", :cik_id=> "0001240500"},
    {:middle=>"R", :first=>"Maurice", :last=>"Greenberg", :cik_id=> "0001236599"},
    {:middle=>"G", :first=>"Peter", :last=>"Peterson", :cik_id=> "0001070843"}, 
    {:first=>"David", :last=>"Rockefeller", :cik_id=> "0001204357"}
]

include SecQuery

describe SecQuery::Entity do
    puts "\n\nCOUNCIL ON FOREIGN RELATIONS' DIRECTORS\nAs perceived by the Security and Exchange Commission Edgar System:\n"
    for t in cfr_directors
        entity = SecQuery::Entity.find(t, true)
        # entity = SecQuery::Entity.find(t, true, {:start => 0, :count => 20, :limit => 20}, {:start => 0, :count => 20, :limit => 20})
        if entity != false
          Entity.log(entity)
          it t[:cik].to_s+" is company "+entity.name.to_s do    
              if t[:cik] != nil
                  entity.cik.should eql(t[:cik_id])
              end
             
         end
        end
    end    
end
