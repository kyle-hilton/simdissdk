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
 * License for source code is in accompanying LICENSE.txt file. If you did
 * not receive a LICENSE.txt with this code, email simdis@nrl.navy.mil.
 *
 * The U.S. Government retains all rights to use, duplicate, distribute,
 * disclose, or release this software.
 *
 */
#include <filesystem>
#include "simCore/System/File.h"

namespace simCore {

FileInfo::FileInfo(const std::string& path)
  : path_(path)
{
}

bool FileInfo::exists() const
{
  std::error_code unused;
  return std::filesystem::exists(path_, unused);
}

bool FileInfo::isRegularFile() const
{
  std::error_code unused;
  return std::filesystem::is_regular_file(path_, unused);
}

bool FileInfo::isDirectory() const
{
  std::error_code unused;
  return std::filesystem::is_directory(path_, unused);
}

}
