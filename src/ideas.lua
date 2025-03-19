function round(v)
 local z=v&0x0.ffff
 if z<0.5 then
  return flr(v)
 else
  return ceil(v)
 end
end
