SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:		Roberto Amaya
-- Ultimo Cambio:	28/05/2018
-- Descripción:		Reporte de Cargas Combustible Utilitarios
-- =============================================
CREATE PROCEDURE [dbo].[rptCargasCombustibleUtilitarios]
    @dInicio AS DATETIME ,
    @dFin AS DATETIME
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  @dInicio = CONVERT(DATETIME, CONVERT(VARCHAR, @dInicio, 110) + ' 00:00:00.000');
        SELECT  @dFin = CONVERT(DATETIME, CONVERT(VARCHAR, @dFin, 110) + ' 23:59:59.999');

        DECLARE @tCargas AS TABLE
            (
              Id INT IDENTITY(1, 1) ,
              Unidad CHAR(10) ,
              FCarga DATETIME ,
              Estacion INT ,
              UEN VARCHAR(10) ,
              Litros REAL ,
              OdoAnt VARCHAR(50) ,
              Odometro VARCHAR(50) ,
              Recorrido DECIMAL ,
              Origen NUMERIC
            )

        INSERT  INTO @tCargas
                ( Unidad ,
                  FCarga ,
                  Estacion ,
                  UEN ,
                  Litros ,
                  OdoAnt ,
                  Odometro ,
                  Origen
                )
                SELECT  CASE WHEN ISNUMERIC(cc.UNIDAD) = 1
                             THEN RIGHT('00000' + LTRIM(RTRIM(CONVERT(VARCHAR(10), CONVERT(INT, cc.UNIDAD)))), 5)
                             WHEN ISNUMERIC(cc.UNIDAD) = 0 THEN RTRIM(cc.UNIDAD)
                        END AS 'Unidad' ,
        --cc.UNIDAD AS 'Unidad' ,
                        cc.FECHA_HORA AS 'Fecha Carga' ,
                        cc.NO_DE_ESTACION AS 'Estación' ,
                        cc.UEN ,
                        cc.VOLUMEN AS 'Litros' ,
                        ( SELECT TOP 1
                                    cc2.ODOMETRO
                          FROM      dbo.ConsumosCombustible AS cc2
                          WHERE     cc2.UNIDAD = cc.UNIDAD
                                    AND cc2.FECHA_HORA < cc.FECHA_HORA
                          ORDER BY  cc2.FECHA_HORA DESC
                        ) AS 'Odom. Ant.' ,
                        cc.ODOMETRO AS 'Odometro' ,
                        cc.ORIGEN AS 'Origen'
                FROM    dbo.ConsumosCombustible AS cc
                        INNER JOIN dbo.CatUtilitarios AS cu ON cu.sUnidad = ( CASE WHEN ISNUMERIC(cc.UNIDAD) = 1
                                                                                   THEN CONVERT(VARCHAR(10), CONVERT(INT, cc.UNIDAD))
                                                                                   WHEN ISNUMERIC(cc.UNIDAD) = 0
                                                                                   THEN RTRIM(cc.UNIDAD)
                                                                              END )
                                                               AND cu.bActivo = 1
                WHERE   cc.FECHA_HORA BETWEEN @dInicio AND @dFin
                ORDER BY 1 ,
                        cc.FECHA_HORA ASC;
                /*SELECT  cc.UNIDAD AS 'Unidad' ,
                        cc.FECHA_HORA AS 'Fecha Carga' ,
                        cc.NO_DE_ESTACION AS 'Estación' ,
                        cc.UEN ,
                        cc.VOLUMEN AS 'Litros' ,
                        ( SELECT TOP 1
                                    cc2.ODOMETRO
                          FROM      dbo.ConsumosCombustible AS cc2
                          WHERE     cc2.UNIDAD = cc.UNIDAD
                                    AND cc2.FECHA_HORA < cc.FECHA_HORA
                          ORDER BY  cc2.FECHA_HORA DESC
                        ) AS 'Odom. Ant.' ,
                        cc.ODOMETRO AS 'Odometro',
						cc.ORIGEN AS 'Origen'
                FROM    dbo.ConsumosCombustible AS cc
                        INNER JOIN dbo.CatUtilitarios AS cu ON cu.sUnidad = cc.UNIDAD AND cu.bActivo = 1
                WHERE   cc.FECHA_HORA BETWEEN @dInicio AND @dFin
                ORDER BY cc.UNIDAD ,
                        cc.FECHA_HORA ASC;*/


        UPDATE  tc
        SET     tc.Recorrido = CAST(tc.Odometro AS DECIMAL) - CAST(tc.OdoAnt AS DECIMAL)
        FROM    @tCargas AS tc

        SELECT  tc.* ,
                tc.Recorrido / tc.Litros AS 'Rendimiento'
        FROM    @tCargas AS tc;
    END

GO