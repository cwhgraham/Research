function lost=DataLost_check(serial_in,reset)
  persistent count;
  if isempty(count) || reset==1
    count=0;
  end
  
  lost=0;
  
  if reset~=1
  if serial_in==0.01
      if count~=65 && count>0
          lost=1;
          fprintf(1,'Data Lost!! count is %d\n',count) % 1 represent print on the screen
      end
      count=0;
  else % temperature data
    count=count+1;
  end
  end
end