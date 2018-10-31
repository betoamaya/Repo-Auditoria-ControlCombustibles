SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================
-- Responsable:		Roberto Amaya
-- Ultimo Cambio:	31/10/2018
-- Descripción:		Muestra y Actualiza el Catalogo de Unidades para Reporte
-- =============================================
CREATE PROCEDURE [dbo].[ActCatUnidadesReporte] @sUnidad AS CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @bActivo AS BIT,
            @Id AS INT;
    IF @sUnidad IS NOT NULL
    BEGIN
        IF (ISNUMERIC(@sUnidad) = 1)
        BEGIN
            SET @sUnidad = CONVERT(VARCHAR(10), CONVERT(INT, @sUnidad));
        END;
        IF EXISTS
        (
            SELECT cu.sUnidad
            FROM dbo.CatUnidadesReporte AS cu
            WHERE cu.sUnidad = RTRIM(@sUnidad)
        )
        BEGIN
            PRINT 'Existe';
            SELECT TOP 1
                @Id = cu.Id,
                @bActivo = cu.bActivo
            FROM dbo.CatUnidadesReporte AS cu
            WHERE cu.sUnidad = RTRIM(@sUnidad)
            ORDER BY cu.sUnidad ASC;
            IF @bActivo = 1
            BEGIN
                SELECT @bActivo = 0;
            END;
            ELSE
            BEGIN
                SELECT @bActivo = 1;
            END;

            UPDATE dbo.CatUnidadesReporte
            SET bActivo = @bActivo,
                dFecha = GETDATE()
            WHERE Id = @Id;
        END;
        ELSE
        BEGIN
            PRINT 'No Existe';
            INSERT INTO dbo.CatUnidadesReporte
            (
                sUnidad,
                dFecha,
                bActivo
            )
            VALUES
            (RTRIM(@sUnidad), GETDATE(), 1);
        END;
    END;

    SELECT cu.sUnidad AS Unidad,
           cu.dFecha AS 'Ultimo Cambio'
    FROM dbo.CatUnidadesReporte AS cu
    WHERE cu.sUnidad = RTRIM(ISNULL(@sUnidad, cu.sUnidad))
          AND cu.bActivo = 1
    ORDER BY cu.sUnidad ASC;
END;

GO