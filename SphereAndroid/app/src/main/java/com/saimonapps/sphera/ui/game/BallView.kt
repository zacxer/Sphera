package com.saimonapps.sphera.ui.game

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.saimonapps.sphera.models.Ball
import com.saimonapps.sphera.models.ShapeType
import kotlin.math.*

@Composable
fun BallView(ball: Ball, size: Dp = 36.dp, modifier: Modifier = Modifier) {
    val main = ball.ballColor.color
    val highlight = ball.ballColor.highlightColor
    val shadow = ball.ballColor.shadowColor

    Canvas(modifier = modifier.size(size)) {
        when (ball.shape) {
            ShapeType.BALL -> drawBallShape(main, highlight, shadow)
            ShapeType.CUBE -> drawCubeShape(main, highlight, shadow)
            ShapeType.PYRAMID -> drawPyramidShape(main, highlight, shadow)
            ShapeType.STAR -> drawStarShape(main, highlight, shadow)
            ShapeType.DIAMOND -> drawDiamondShape(main, highlight, shadow)
        }
    }
}

private fun DrawScope.drawBallShape(main: androidx.compose.ui.graphics.Color, highlight: androidx.compose.ui.graphics.Color, shadow: androidx.compose.ui.graphics.Color) {
    val r = size.minDimension / 2f
    val cx = size.width / 2f
    val cy = size.height / 2f
    drawCircle(shadow, r * 0.9f, Offset(cx + r * 0.1f, cy + r * 0.1f))
    drawCircle(
        Brush.radialGradient(
            colors = listOf(highlight, main, shadow),
            center = Offset(cx - r * 0.2f, cy - r * 0.2f),
            radius = r
        ),
        r, Offset(cx, cy)
    )
    drawCircle(highlight, r * 0.25f, Offset(cx - r * 0.3f, cy - r * 0.3f))
}

private fun DrawScope.drawCubeShape(main: androidx.compose.ui.graphics.Color, highlight: androidx.compose.ui.graphics.Color, shadow: androidx.compose.ui.graphics.Color) {
    val pad = size.minDimension * 0.1f
    val w = size.width - pad * 2
    val h = size.height - pad * 2
    val x = pad; val y = pad
    drawRect(shadow, Offset(x + 2, y + 2), Size(w, h))
    drawRect(
        Brush.linearGradient(colors = listOf(highlight, main, shadow),
            start = Offset(x, y), end = Offset(x + w, y + h)),
        Offset(x, y), Size(w, h)
    )
    drawLine(highlight.copy(alpha = 0.5f), Offset(x, y), Offset(x + w, y), 1.5f)
    drawLine(highlight.copy(alpha = 0.5f), Offset(x, y), Offset(x, y + h), 1.5f)
}

private fun DrawScope.drawPyramidShape(main: androidx.compose.ui.graphics.Color, highlight: androidx.compose.ui.graphics.Color, shadow: androidx.compose.ui.graphics.Color) {
    val path = Path().apply {
        moveTo(size.width / 2f, size.height * 0.1f)
        lineTo(size.width * 0.9f, size.height * 0.9f)
        lineTo(size.width * 0.1f, size.height * 0.9f)
        close()
    }
    drawPath(path, shadow.copy(alpha = 0.6f))
    drawPath(path, Brush.verticalGradient(colors = listOf(highlight, main, shadow)))
}

private fun DrawScope.drawStarShape(main: androidx.compose.ui.graphics.Color, highlight: androidx.compose.ui.graphics.Color, shadow: androidx.compose.ui.graphics.Color) {
    val cx = size.width / 2f; val cy = size.height / 2f
    val outerR = size.minDimension / 2f * 0.9f
    val innerR = outerR * 0.45f
    val path = Path()
    for (i in 0 until 10) {
        val angle = Math.toRadians((i * 36.0 - 90.0))
        val r = if (i % 2 == 0) outerR else innerR
        val x = cx + r * cos(angle).toFloat()
        val y = cy + r * sin(angle).toFloat()
        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
    }
    path.close()
    drawPath(path, shadow.copy(alpha = 0.6f))
    drawPath(path, Brush.radialGradient(colors = listOf(highlight, main, shadow), center = Offset(cx, cy), radius = outerR))
}

private fun DrawScope.drawDiamondShape(main: androidx.compose.ui.graphics.Color, highlight: androidx.compose.ui.graphics.Color, shadow: androidx.compose.ui.graphics.Color) {
    val cx = size.width / 2f; val cy = size.height / 2f
    val path = Path().apply {
        moveTo(cx, cy - size.height * 0.45f)
        lineTo(cx + size.width * 0.45f, cy)
        lineTo(cx, cy + size.height * 0.45f)
        lineTo(cx - size.width * 0.45f, cy)
        close()
    }
    drawPath(path, shadow.copy(alpha = 0.6f))
    drawPath(path, Brush.radialGradient(colors = listOf(highlight, main, shadow), center = Offset(cx - cx * 0.2f, cy - cy * 0.2f), radius = size.minDimension / 2f))
    drawLine(highlight.copy(alpha = 0.6f), Offset(cx, cy - size.height * 0.45f), Offset(cx + size.width * 0.45f, cy), 1f)
}
