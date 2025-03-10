Copyright>        OpenRadioss
Copyright>        Copyright (C) 1986-2023 Altair Engineering Inc.
Copyright>
Copyright>        This program is free software: you can redistribute it and/or modify
Copyright>        it under the terms of the GNU Affero General Public License as published by
Copyright>        the Free Software Foundation, either version 3 of the License, or
Copyright>        (at your option) any later version.
Copyright>
Copyright>        This program is distributed in the hope that it will be useful,
Copyright>        but WITHOUT ANY WARRANTY; without even the implied warranty of
Copyright>        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Copyright>        GNU Affero General Public License for more details.
Copyright>
Copyright>        You should have received a copy of the GNU Affero General Public License
Copyright>        along with this program.  If not, see <https://www.gnu.org/licenses/>.
Copyright>
Copyright>
Copyright>        Commercial Alternative: Altair Radioss Software
Copyright>
Copyright>        As an alternative to this open-source version, Altair also offers Altair Radioss
Copyright>        software under a commercial license.  Contact Altair to discuss further if the
Copyright>        commercial version may interest you: https://www.altair.com/radioss/.
Chd|====================================================================
Chd|  READ_EULER_MAT                source/materials/ale/read_euler_mat.F
Chd|-- called by -----------
Chd|        READ_MATERIAL_MODELS          source/materials/read_material_models.F
Chd|-- calls ---------------
Chd|        HM_GET_FLOATV                 source/devtools/hm_reader/hm_get_floatv.F
Chd|        HM_OPTION_COUNT               source/devtools/hm_reader/hm_option_count.F
Chd|        HM_OPTION_IS_ENCRYPTED        source/devtools/hm_reader/hm_option_is_encrypted.F
Chd|        HM_OPTION_READ_KEY            source/devtools/hm_reader/hm_option_read_key.F
Chd|        HM_OPTION_START               source/devtools/hm_reader/hm_option_start.F
Chd|        ALEFVM_MOD                    ../common_source/modules/ale/alefvm_mod.F
Chd|        HM_OPTION_READ_MOD            share/modules1/hm_option_read_mod.F
Chd|        MESSAGE_MOD                   share/message_module/message_mod.F
Chd|        SUBMODEL_MOD                  share/modules1/submodel_mod.F 
Chd|====================================================================
      SUBROUTINE READ_EULER_MAT(LSUBMODEL,UNITAB,IPM,PM)
C-----------------------------------------------
C   D e s c r i p t i o n
C-----------------------------------------------
C  This subroutine is reading keyword /EULER/MAT
C  and setting corresponding parameters in materail buffer (PM array)
C-----------------------------------------------
C   M o d u l e s
C-----------------------------------------------
      USE UNITAB_MOD
      USE MESSAGE_MOD
      USE SUBMODEL_MOD
      USE HM_OPTION_READ_MOD
      USE ALEFVM_MOD , only:ALEFVM_Param
C-----------------------------------------------
C   I m p l i c i t   T y p e s
C-----------------------------------------------
#include      "implicit_f.inc"
C-----------------------------------------------
C   C o m m o n   B l o c k s
C-----------------------------------------------
#include      "scr17_c.inc"
#include      "com04_c.inc"
#include      "param_c.inc"
#include      "units_c.inc"
#include      "submod_c.inc"
C-----------------------------------------------
C   D u m m y   A r g u m e n t s
C-----------------------------------------------
      INTEGER ,DIMENSION(NPROPMI,NUMMAT), INTENT(INOUT)   :: IPM
      my_real ,DIMENSION(NPROPM ,NUMMAT), INTENT(INOUT)   :: PM
      TYPE (UNIT_TYPE_) ,INTENT(IN) :: UNITAB 
      TYPE(SUBMODEL_DATA) ,DIMENSION(NSUBMOD) , INTENT(IN)    :: LSUBMODEL
C-----------------------------------------------
C   L o c a l   V a r i a b l e s
C-----------------------------------------------
      my_real :: FLRD
      INTEGER II,KK,NB_EULERMAT,ILAW,ID
      CHARACTER TITR*nchartitle,KEY*80
      LOGICAL IS_AVAILABLE,IS_ENCRYPTED
C-----------------------------------------------
C   S o u r c e   L i n e s
C-----------------------------------------------
        CALL HM_OPTION_COUNT('/EULER/MAT',NB_EULERMAT)
        CALL HM_OPTION_START('/EULER/MAT')
        
        DO KK=1,NB_EULERMAT
          CALL HM_OPTION_READ_KEY(LSUBMODEL, OPTION_ID=ID)
          CALL HM_OPTION_IS_ENCRYPTED(IS_ENCRYPTED)
          CALL HM_GET_FLOATV('EULER_FLRD',FLRD,IS_AVAILABLE,LSUBMODEL,UNITAB)
          DO II=1,NUMMAT-1                                
            IF(IPM(1,II) == ID)THEN                        
                ILAW = IPM(2,II)                          
              IF(ILAW == 11)THEN                         
                IF(FLRD == ZERO) FLRD=ONE                 
              ELSE                                       
                FLRD=MAX(ZERO,FLRD)                      
                FLRD=MIN(ONE,FLRD)                        
              ENDIF                                      
              PM(72,II)  = TWOP1                         
              PM(92,II)  = FLRD                             
              WRITE(IOUT,2020)ID,FLRD                                                          
            ENDIF                                        
          ENDDO                                          
        ENDDO
        
 2020 FORMAT(
     & 5X,'    EULERIAN MATERIAL  ',/,
     & 5X,'    -----------------  ',/,
     & 5X,'MATERIAL NUMBER . . . . . . . . . . . .=',I10/,
     & 5X,'REDUCTION FACTOR ON BOUNDARY FLUXES . .=',1PG20.13//)
             
      RETURN
      END SUBROUTINE READ_EULER_MAT
