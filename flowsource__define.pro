; docformat = 'rst'

;+
; Flow field $\vec{u}(\vec{r})$
; at specified points $\vec{r}$
; due to a localized source
; of flow consisting of an Oseen tensor $\mathsf{G}(\vec{r})$
; and a driving force $\vec{f}_0$.
; $$\vec{u}(\vec{r}) =
;    \mathsf{G}(\vec{r} - \vec{r}_0) \cdot \vec{f}_0
; $$
;
; :Properties:
;    oseentensor
;        Reference to the `oseentensor` object describing the source,
;        $\mathsf{G}(\vec{r})$.
;    force
;        3-element vector describing the force $\vec{f}_0$
;        responsible for the flow.
;
; :Author:
;    David G. Grier, New York University
;
; :Copyright:
;    Copyright (c) 2015 David G. Grier
;-

;+
; Calculate the flow velocity at r due to the specified source.
;
; :Params:
;    r : in, required, type=`fltarr(3,N)`
;        Array of N Cartesian coordinates.
;
; :Keywords:
;    _extra : in, optional, type=keywords
;        Keywords for the Compute() method of
;        the `oseentensor`.
;
; :Returns:
;    3xN array of velocity vectors at each coordinate.
;-
function flowsource::Compute, r, $
                              _extra = extra

  COMPILE_OPT IDL2, HIDDEN

  if n_elements(r[*, 0]) ne 3 then $
     return, [0, 0, 0]
  
  npts = n_elements(r) / 3
  v = 0.*r
  for i = 0, npts-1 do $
     v[*, i] = self.oseentensor.compute(r[*, i], _extra = extra) # self.force
  return, v
end

;+
; flowsource::SetProperty
;
; :Keywords:
;    _extra : type=keywords
;        Keywords for `oseentensor`
;-
pro flowsource::SetProperty, force = force, $
                             _extra = re

  COMPILE_OPT IDL2, HIDDEN

  if isa(force, /number, /array) && n_elements(force) eq 3 then $
     self.force = float(force)

  self.oseentensor.Setproperty, _extra = re
end

;+
; flowsource::GetProperty
;
; :Keywords:
;    _ref_extra : hidden
;-
pro flowsource::GetProperty, force = force, $
                             oseentensor = oseentensor, $
                            _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(force) then force = self.force
  if arg_present(oseentensor) then oseentensor = self.oseentensor

  self.oseentensor.Getproperty, _extra = re
end

;+
; flowsource::Init(oseentensor)
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    oseentensor : in, optional, type=`oseentensor`
;        Reference to `oseentensor` object describing flow.
;
; :Keywords:
;    force : in, optional, type=`fltarr(3)`
;        Force vector in units of newtons
;    _ref_extra : in, hidden
;-
function flowsource::Init, oseentensor, $
                           force = force, $
                           _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if isa(oseentensor, 'oseentensor') then begin
     self.oseentensor = oseentensor
     self.oseentensor.setproperty, _extra = re
  endif else begin
     oseentensor = oseentensor(_extra = re)
     self.oseentensor = oseentensor
  endelse
  
  if isa(force, /number, /array) && n_elements(force) eq 3 then $
     self.force = float(force) $
  else begin
     force = [0., 0., 1.]
     self.force = force
  endelse

  return, 1B
end

;+
; flowsource__define
;
; :Fields:
;    oseentensor
;        Reference to an `oseentensor` object describing the
;        flow source.
;    force
;        3-element array describing force creating the flow
;        at the source.
;
; :Hidden:
;-
pro flowsource__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {flowsource, $
            inherits IDL_Object, $
            oseentensor: obj_new(), $
            force: findgen(3) $
           }
end
