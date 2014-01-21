function [x,y,typ] = rtai4_comedi_encoder(job,arg1,arg2)
  x=[];y=[];typ=[];
  format(12);
  select job
  case 'plot' then
    exprs=arg1.graphics.exprs;
    number=exprs(1)
    name=exprs(2)
    standard_draw(arg1)
  case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
  case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
  case 'getorigin' then
    [x,y]=standard_origin(arg1)
  case 'set' then
    x=arg1
    model=arg1.model;graphics=arg1.graphics;
    exprs=graphics.exprs;
    while %t do
      [ok, number, name, chA, chB, chZ, initval, index, cmode, map, exprs]=..
      scicos_getvalue(['Set RTAI-COMEDI Encoder block parameters';
                'For NI cards in up/down mode, set B to -1';
                'to input the up/down signal on P0.6 or P0.7'],..
      ['Counter No';
      'Device';
      'A PFI';
      'B PFI';
      'Z PFI';
      'Initial value';
      'Enable Index (0:no, 1:yes)';
      'Mode (0:up/down,1:X1,2:X2,4:X4)';
      'Map on channels (0:no, 1:yes)'],..
      list('vec',1,'str',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      if exists('outport') then out=ones(outport,1), in=[], else out=1, in=[], end
      [model,graphics,ok]=check_io(model,graphics,in,out,1,[])
      dev=str2code(name)
      if ok then
        graphics.exprs=exprs;
        model.ipar=[number;
                    chA;
                    chB;
                    chZ;
                    initval;
                    index;
                    cmode;
		    map;
                    dev(length(dev))];
        model.rpar=[];
        model.dstate=[];
        x.graphics=graphics;x.model=model
        break
      end
    end
  case 'define' then
    number=0
    name='comedi0'
    chA=8
    chB=10
    chZ=9
    initval=2147483648
    index=0
    cmode=4
    map=0
    model=scicos_model()
    model.sim=list('rt_comedi_encoder',4)
    if exists('outport') then model.out=ones(outport,1), model.in=[], else model.out=1, model.in=[], end
    model.evtin=1
    model.rpar=[]
    model.ipar=[number;
                chA;
                chB;
                chZ;
                initval;
                index;
                cmode;
		map;
                0]
    model.dstate=[];
    model.blocktype='d'
    model.dep_ut=[%t %f]
    exprs=[sci2exp(number);name;sci2exp(chA);sci2exp(chB);sci2exp(chZ);sci2exp(initval);sci2exp(index);sci2exp(cmode);sci2exp(map)]
    gr_i=['xstringb(orig(1),orig(2),[''COMEDI Encoder'';name+'' CTR-''+string(number)],sz(1),sz(2),''fill'');']
    x=standard_define([3 2],model,exprs,gr_i)
  end
endfunction
