/* -*- mode: c++ -*- */
/****************************************************************************
 *****                                                                  *****
 *****                   Classification: UNCLASSIFIED                   *****
 *****                    Classified By:                                *****
 *****                    Declassify On:                                *****
 *****                                                                  *****
 ****************************************************************************
 *
 *
 * Developed by: Naval Research Laboratory, Tactical Electronic Warfare Div.
 *               EW Modeling & Simulation, Code 5773
 *               4555 Overlook Ave.
 *               Washington, D.C. 20375-5339
 *
 * License for source code can be found at:
 * https://github.com/USNavalResearchLaboratory/simdissdk/blob/master/LICENSE.txt
 *
 * The U.S. Government retains all rights to use, duplicate, distribute,
 * disclose, or release this software.
 *
 */
#ifndef SIMQT_ColorGradientWidget2_H
#define SIMQT_ColorGradientWidget2_H

#include <memory>
#include <QColor>
#include <QWidget>
#include "simCore/Common/Export.h"
#include "simQt/ColorGradient.h"

class QGroupBox;
class QSortFilterProxyModel;
class QTreeView;
class Ui_ColorGradientWidget2;

namespace simQt {

/** Qt widget that enables customization of a multi-stop color gradient */
class SDKQT_EXPORT ColorGradientWidget2 : public QWidget
{
  Q_OBJECT;

  /** Shows/hides the gradient stop list below the display widget */
  Q_PROPERTY(bool ShowTable READ showTable WRITE setShowTable)
  /** Show/hide alpha in displayed color selectors */
  Q_PROPERTY(bool ShowAlpha READ showAlpha WRITE setShowAlpha)

public:
  /** Constructor */
  explicit ColorGradientWidget2(QWidget* parent = NULL);
  virtual ~ColorGradientWidget2();

  /**
   * Sets the current gradient to the given ColorGradient.
   * Emits gradientChanged() only if changed.
   */
  void setColorGradient(const ColorGradient& gradient);
  ColorGradient getColorGradient() const;

  /** Removes all colors and stops. */
  void clear();

  /** Returns true if the color stops table is displayed */
  bool showTable() const;
  /** Returns true if the color editors will show alpha values */
  bool showAlpha() const;

public slots:
  /** Sets whether to display the color stops table */
  void setShowTable(bool show);
  /** Sets whether the color editors will allow editing of alpha values */
  void setShowAlpha(bool show);

signals:
  /** Emitted whenever a change is made to the stored color gradient */
  void gradientChanged(const simQt::ColorGradient& gradient);

private slots:
  /**  */
  void emitGradientChanged_();

private:
  /** Creates or destroys the stops table based on showTable_ flag */
  void showOrHideTable_();

  std::unique_ptr<Ui_ColorGradientWidget2> ui_;
  QGroupBox* tableGroup_;
  QTreeView* treeView_;

  class ColorGradientModel;
  ColorGradientModel* model_;
  QSortFilterProxyModel* proxyModel_;

  class GradientDisplayWidget;

  bool showTable_;
  bool showAlpha_;
};
}

#endif /* SIMQT_ColorGradientWidget2_H */
