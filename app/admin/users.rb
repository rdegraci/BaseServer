ActiveAdmin.register User do
  
  controller do
    def update
      # Do not always update the password
      if params[:user][:password].blank?
        params[:user].delete("password")   
        params[:user].delete("password_confirmation")
      end
    end
  end
  
  index do
    selectable_column
    column :id                            
    column :email                                 
    default_actions                   
  end                                 

  filter :email   
  
  show do |user|                    
    attributes_table do
      row :email
    end
  end
  

  form do |f|                         
    f.inputs "User Details" do       
      f.input :email                  
      f.input :password               
      f.input :password_confirmation  
    end                               
    f.actions                         
  end                                 
                              
end
