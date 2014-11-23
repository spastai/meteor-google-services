###
Not used in google services - just copied

Chains methods in the queue and in every iteration calls original callback and next function
Thus all functions has to be (error, result) signature

A---cb
    |__B---cb

# Has bad bug - if method doesn't call calback - the chain is broken
###
class @SequenceQueue
  idle: true
  
  constructor: (context) ->
    @context = context
    @actions = [];
    
  push: (fn, originalCb) =>
    #d "Push, idle:"+@idle
    if originalCb
      #d "Callback provided - normalize to f(cb, err, result) format"
      fnO = (next) =>
        fn.bind(@context)((err, result) =>
          originalCb.bind(@context)(err, result)
          next.bind(@context)())
      @actions.push fnO
    else
      @actions.push fn.bind(@context)

  run: (fn, originalCb) =>
    #d "Run, queue:"+@actions.length+new Error().stack
    if(fn)
      @push(fn, originalCb);
    if @idle
      #d "Idle:"+@idle 
      @runActions()         

  runActions: () =>
    #d "execute:", @actions.length
    @idle = false
    fn = @listDone.bind(@)
    list = _(@actions).reduceRight(_.wrap, fn);  
    @actions = [];
    list();
    
  listDone: () =>
    if(@actions.length > 0) 
      @runActions();
    else
      @idle = true
