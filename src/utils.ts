
export type EVCb<T> = (err: any, val?: T) => void;

export const getUniqueList =  (a: Array<any>) : Array<any> => {
  
  const set = new Set<any>();
  
  for(let i = 0; i < a.length; i++){
    if(!set.has(a[i])){
      set.add(a[i]);
    }
  }
  
  return Array.from(set.values());
  
};


export const flattenDeep = (a: Array<any>) : Array<any> => {
  return a.reduce((acc, val) => Array.isArray(val) ? acc.concat(flattenDeep(val)) : acc.concat(val), []);
};
